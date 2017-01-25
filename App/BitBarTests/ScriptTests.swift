import Quick
import Cent
import Nimble
@testable import BitBar

public func beASuccess() -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "exit with status 0"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch result {
      case Script.Result.success(_, 0):
        return true
      default:
        failureMessage.postfixActual = String(describing: result)
        return false
    }
  }
}

public func beASuccess(with exp: String) -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "exit with status 0 and output '\(exp)'"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch result {
      case let Script.Result.success(actual, 0) where actual == exp:
        return true
      default:
        failureMessage.postfixActual = String(describing: result)
        return false
    }
  }
}

public func beTerminated() -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "terminated"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch result {
      case Script.Result.failure(.terminated()):
        return true
      default:
        failureMessage.postfixActual = String(describing: result)
        return false
    }
  }
}

class ScriptTests: Helper {
  let timeout = 10.0
  func toFile(_ path: String) -> String {
    return Bundle(for: ScriptTests.self).resourcePath! + "/" + path
  }

  func toStream(_ items: String...) -> [String] {
    return items.map { item in item + "\n~~~\n" }
  }

  func testSucc(_ path: String, args: [String] = [], assumed: String) {
    waitUntil(timeout: timeout) { done in
      let _ = Script(path: self.toFile(path), args: args, autostart: true) { result in
        switch result {
          case let .success(stdout, status):
            expect(stdout).to(equal(assumed))
            expect(status).to(equal(0))
          default:
            fail("Expected success but got \(result)")
        }
        done()
      }
    }
  }

  func testStream(_ path: String, args: [String] = [], assumed: [String]) {
    if assumed.isEmpty { fail("Assumed can't be empty'") }
    waitUntil(timeout: timeout) { done in
      var index = 0
      var script: Script!
      script = Script(path: self.toFile(path), args: args, autostart: true) { result in
        let description = String(describing: result)
        if index == -1 {
          return fail("To many calls. Max is \(assumed.count) \(path): \(description)")
        }

        if !assumed.indices.contains(index) {
          fail("Script was called to many times. \(description)")
          index = -1
          return done()
        }

        expect(result).to(beASuccess(with: assumed[index]))

        index += 1
        if assumed.count == index {
          done()
          script.stop()
          index = -1
        }
      }
    }
  }

  func testFail(_ path: String, args: [String] = [], assumed: String) {
    waitUntil(timeout: timeout) { done in
      let _ = Script(path: self.toFile(path), args: args, autostart: true) { result in
        switch result {
          case let .failure(.exit(stderr, status)):
            expect(stderr).to(equal(assumed))
            expect(status).toNot(equal(0))
          default:
            fail("Expected failure but got \(result)")
        }
        done()
      }
    }
  }

  func testCrash(_ path: String, args: [String] = [], assumed: String) {
    waitUntil(timeout: timeout) { done in
      let _ = Script(path: self.toFile(path), args: args, autostart: true) { result in
        switch result {
          case let .failure(.crash(message)):
            expect(message).to(equal(assumed))
          default:
            fail("Expected success but got \(result)")
        }
        done()
      }
    }
  }

  func testMisuse(_ path: String, args: [String] = [], assumed: String) {
    waitUntil(timeout: timeout) { done in
      let _ = Script(path: self.toFile(path), args: args, autostart: true) { result in
        switch result {
          case let .failure(.misuse(message)):
            expect(message).to(contain(assumed))
          default:
            fail("Expected misuse but got \(result)")
        }
        done()
      }
    }
  }

  override func spec() {
    describe("stdout") {
      it("handles base case") {
        self.testSucc("basic.sh", assumed: "Hello")
      }

      it("handles sleep") {
        self.testSucc("sleep.sh", assumed: "sleep")
      }

      it("handles args") {
        self.testSucc("args.sh", args: ["1", "2", "3"], assumed: "1 2 3")
      }

      it("handles file with space in name") {
        self.testSucc("space script.sh", assumed: "Hello")
      }
    }

    describe("stderr") {
      it("exit code 1, no output") {
        self.testFail("exit1-no-output.sh", assumed: "")
      }

      it("exit code 1, with output") {
        self.testFail("exit1-output.sh", assumed: "Exit 1")
      }
    }

    describe("crash") {
      it("is missing shebang") {
        self.testCrash("missing-sh-bin.sh", assumed: "launch path not accessible")
      }

      it("handles non-executable script") {
        self.testCrash("nonexec.sh", assumed: "launch path not accessible")
      }

      it("handles non-existing file") {
        self.testCrash("does-not-exist.sh", assumed: "launch path not accessible")
      }
    }

    describe("misuse") {
      it("handles invalid syntax") {
        self.testMisuse("invalid-syntax.sh", assumed: "syntax error: unexpected end of file")
      }
    }

    describe("stream") {
      it("handles one output") {
        self.testStream("stream-nomore.sh", assumed: ["A\n~~~"])
      }

      it("handles more then one") {
        self.testStream("stream-more.sh", assumed: ["A\n~~~", "B"])
      }

      it("handles empty stream") {
        self.testStream("stream-nothing.sh", assumed: ["~~~"])
      }

      it("handles sleep") {
        self.testStream("stream-sleep.sh", assumed: ["A\n~~~", "B"])
      }
    }

    describe("start/stop") {
      let path = self.toFile("sleep.sh")
      it("doesn't auto start'") {
        var index = 0
        let _ = Script(path: path) { output in
          expect(output).to(beASuccess())
          index += 1
        }

        expect(index).toEventuallyNot(beGreaterThan(0))
      }

      it("should autostart") {
        var index = 0
        let _ = Script(path: path, autostart: true) { output in
          expect(output).to(beASuccess())
          index += 1
        }

        expect(index).toEventually(equal(1), timeout: 10)
      }

      it("stop running task") {
        var index = 0
        let script = Script(path: path) { output in
          expect(output).to(beTerminated())
          index += 1
        }

        script.stop()

        expect(index).toEventuallyNot(beGreaterThan(0))
      }

      it("should cancel already running scripts") {
        var index = 0
        let script = Script(path: path, autostart: false) { output in
          if index == 4 {
            expect(output).to(beASuccess())
          } else {
            expect(output).to(beTerminated())
          }
          index += 1
        }

        for _ in 0..<5 {
          script.start()
        }

        expect(index).toEventually(equal(5), timeout: self.timeout)
      }

      it("should be able to restart script") {
        var index = 0
        let script = Script(path: path, autostart: true) { output in
          if index == 1 {
            expect(output).to(beASuccess())
          } else {
            expect(output).to(beTerminated())
          }
          index += 1
        }

        script.restart()

        expect(index).toEventually(equal(2), timeout: self.timeout)
        expect(index).toEventuallyNot(beGreaterThan(2))
      }

      it("should be able to stop a non running script") {
        var index = 0
        let script = Script(path: path, autostart: false) { _ in
          index += 1
        }

        script.stop()
        expect(index).toEventuallyNot(beGreaterThan(1))
      }
    }
  }
}
