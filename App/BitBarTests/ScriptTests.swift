import Quick
import Nimble
@testable import BitBar

let toFile = { file in Bundle(for: ScriptTests.self).resourcePath! + "/" + file }

class Out {
  let out: String
  let code: Int32

  init(_ out: String, _ code: Int32) {
    self.out = out
    self.code = code
  }
}

class AScript: ScriptDelegate {
  var result: Out = Out("", Int32(10))

  func scriptDidReceiveOutput(_ output: String) {
    result = Out(output.noMore(), Int32(0))
  }

  func scriptDidReceiveError(_ error: String, _ code: Int32) {
    result = Out(error.noMore(), code)
  }
}

class ScriptTests: QuickSpec {
  func testScript(_ path: String) -> AScript {
    return testScript(path, args: [])
  }

  func testScript(_ path: String, args: [String]) -> AScript {
    let del = AScript()
    let script = Script(path: toFile(path), args: args, delegate: del)
    script.start()
    return del
  }

  override func spec() {
    describe("stdout") {
      it("handles base case") {
        // let del = self.testScript("hello.sh")
        // expect(del.result.code).toEventually(equal(0))
        // expect(del.result.out).toEventually(equal("Hello"))
      }

      it("handles sleep") {
        let del = self.testScript("sleep.sh")
        expect(del.result.code).toEventually(equal(0), timeout: 2)
        expect(del.result.out).toEventually(equal("sleep"), timeout: 2)
      }

      it("handles args") {
        let del = self.testScript("args.sh", args: ["1", "2", "3"])
        expect(del.result.code).toEventually(equal(0))
        expect(del.result.out).toEventually(equal("1 2 3"))
      }
    }

    describe("stderr") {
      it("exit code 1, no output") {
        let del = self.testScript("exit1-no-output.sh")
        expect(del.result.code).toEventually(equal(1))
        expect(del.result.out).toEventually(equal(""))
      }

      it("exit code 1, with output") {
        let del = self.testScript("exit1-output.sh")
        expect(del.result.code).toEventually(equal(1))
        expect(del.result.out).toEventually(equal("Exit 1"))
      }

      // TODO:
      // it("missing shebang") {
      //   let del = self.testScript("missing-sh-bin.sh")
      //   expect(del.result.code).toEventually(equal(1))
      //   expect(del.result.out).toEventually(equal("Exit 1"))
      // }
    }
  }
}
