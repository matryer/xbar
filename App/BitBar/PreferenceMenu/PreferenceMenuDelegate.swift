protocol PreferenceMenuDelegate: class {
  func preferenceDidRefreshAll()
  func preferenceDidQuit()
  func preferenceDidChangePluginFolder()
}
