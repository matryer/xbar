protocol ScriptDelegate: class {
  func scriptDidReceiveOutput(_ result: String, _ code: Int32)
  func scriptDidReceiveError(_ result: String, _ code: Int32)
}
