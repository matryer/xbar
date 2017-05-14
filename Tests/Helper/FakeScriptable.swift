@testable import BitBar

class FakeScriptable: ScriptDelegate {
  var result = [Std]()

  init() {}

  func scriptDidReceive(success: Script.Success) {
    result.append(.succ(success))
  }

  func scriptDidReceive(failure: Script.Failure) {
    result.append(.fail(failure))
  }
}
