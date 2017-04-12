import Quick
import Nimble
@testable import BitBar

class ScriptTests: Helper {
  let timeout = 10.0

  func testSucc(_ path: String, args: [String] = [], assumed: String) {
    waitUntil(timeout: timeout) { done in
      let _ = Script(path: toFile(path), args: args, autostart: true) { result in
        expect(result).to(beASuccess(with: assumed))
        done()
      }
    }
  }

  func testStream(_ path: String, args: [String] = [], assumed: [String]) {
    if assumed.isEmpty { fail("Assumed can't be empty'") }
    var index = 0
    waitUntil(timeout: timeout) { done in
      let _ = Script(path: toFile(path), args: args, autostart: true) { result in
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
          index = -1
        }
      }
    }
  }

  func testFail(_ path: String, args: [String] = [], assumed: String) {
    waitUntil(timeout: timeout) { done in
      let _ = Script(path: toFile(path), args: args, autostart: true) { result in
        expect(result).to(beAFailure(with: assumed))
        done()
      }
    }
  }

  func testCrash(_ path: String, args: [String] = [], assumed: String) {
    waitUntil(timeout: timeout) { done in
      let _ = Script(path: toFile(path), args: args, autostart: true) { result in
        expect(result).to(beACrash(with: assumed))
        done()
      }
    }
  }

  func testMisuse(_ path: String, args: [String] = [], assumed: String) {
    waitUntil(timeout: timeout) { done in
      let _ = Script(path: toFile(path), args: args, autostart: true) { result in
        expect(result).to(beAMisuse(with: assumed))
        done()
      }
    }
  }

  override func spec() {
    describe("stdout") {
      it("handles base case") {
        self.testSucc("basic.sh", assumed: "Hello\n")
      }

      it("handles sleep") {
        self.testSucc("sleep.sh", assumed: "sleep\n")
      }

      it("handles args") {
        self.testSucc("args.sh", args: ["1", "2", "3"], assumed: "1 2 3\n")
      }

      it("handles file with space in name") {
        self.testSucc("space script.sh", assumed: "Hello\n")
      }
    }

    describe("stderr") {
      it("exit code 1, no output") {
        self.testFail("exit1-no-output.sh", assumed: "")
      }

      it("exit code 1, with output") {
        self.testFail("exit1-output.sh", assumed: "Exit 1\n")
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
        self.testStream("stream-nomore.sh", assumed: ["A\n~~~\n"])
      }

      it("handles more then one") {
        self.testStream("stream-more.sh", assumed: ["A\n~~~\n", "B\n"])
      }

      it("handles empty stream") {
        self.testStream("stream-nothing.sh", assumed: ["~~~\n"])
      }

      it("handles sleep") {
        self.testStream("stream-sleep.sh", assumed: ["A\n~~~\n", "B\n"])
      }
    }

    describe("start/stop") {
      let path = toFile("sleep.sh")
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
