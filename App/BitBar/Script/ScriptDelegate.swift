protocol ScriptDelegate: class {
  func scriptDidReceiveOutput(_ result: String)
  func scriptDidReceiveError(_ result: String, _ code: Int32)
}
