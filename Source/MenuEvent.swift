enum MenuEvent: Comparable {
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
  case openOnLogin
  case doNotOpenOnLogin
  case openUrlInBrowser(String)
  case openScriptInTerminal(String)

  public static func < (lhs: MenuEvent, rhs: MenuEvent) -> Bool {
    return String(describing: lhs).characters.count < String(describing: rhs).characters.count
  }

  public static func == (lhs: MenuEvent, rhs: MenuEvent) -> Bool {
    switch (lhs, rhs) {
    case (.refreshAll, .refreshAll): fallthrough
    case (.quitApplication, .quitApplication): fallthrough
    case (.openPluginFolder, .openPluginFolder): fallthrough
    case (.openWebsite, .openWebsite): fallthrough
    case (.changePluginPath, .changePluginPath): fallthrough
    case (.didSetError, .didSetError): fallthrough
    case (.refreshPlugin, .refreshPlugin): fallthrough
    case (.checkForUpdates, .checkForUpdates): fallthrough
    case (.runInTerminal, .runInTerminal): fallthrough
    case (.newPluginData, .newPluginData): fallthrough
    case (.openOnLogin, .openOnLogin): fallthrough
    case (.doNotOpenOnLogin, .doNotOpenOnLogin): fallthrough
    case (.refreshAll, .refreshAll):
      return true
    case let (.openUrlInBrowser(url1), .openUrlInBrowser(url2)):
      return url1 == url2
    case let (.openScriptInTerminal(script1), .openScriptInTerminal(script2)):
      return script1 == script2
    default:
      return false
    }
  }
}
