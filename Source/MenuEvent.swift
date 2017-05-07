enum MenuEvent {
  case refreshAll
  case quitApplication
  case openPluginFolder
  case openWebsite
  case changePluginPath
  case didSetError
  case refreshPlugin
  case checkForUpdates
  case runInTerminal
  case newPluginData
  case startOnLogin(Bool)
}
