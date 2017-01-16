protocol TrayDelegate: class {
  func preferenceDidRefreshAll()
  func preferenceDidQuit()
  func preferenceDidChangePluginFolder()
}
