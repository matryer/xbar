import Quick
import Cent
import Nimble
@testable import BitBar

class ScriptTests: Helper {
  let timeout = 10.0

  func toFile(_ path: String) -> String {
    return Bundle(for: ScriptTests.self).resourcePath! + "/" + path
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
    }

    describe("misuse") {
      it("handles invalid syntax") {
        self.testMisuse("invalid-syntax.sh", assumed: "syntax error: unexpected end of file")
      }
    }
  }
}
