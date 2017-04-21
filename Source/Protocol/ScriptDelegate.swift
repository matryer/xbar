protocol ScriptDelegate: class {
  func scriptDidReceive(success: Script.Result)
  func scriptDidReceive(error: Script.Result)
}
