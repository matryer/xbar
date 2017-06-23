import Parser

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
  case installCommandLineInterface
  case openUrlInBrowser(String)
  case openScriptInTerminal(Action.Script)
  case openPathInTerminal(String)

  public static func < (lhs: MenuEvent, rhs: MenuEvent) -> Bool {
    return String(describing: lhs).characters.count < String(describing: rhs).characters.count
  }

  public static func == (lhs: MenuEvent, rhs: MenuEvent) -> Bool {
    switch (lhs, rhs) {
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
    case (.installCommandLineInterface, .installCommandLineInterface): fallthrough
    case (.refreshAll, .refreshAll):
      return true
    case let (.openUrlInBrowser(u1), openUrlInBrowser(u2)):
      return u1 == u2
    case let (.openScriptInTerminal(s1), .openScriptInTerminal(s2)):
      return s1 == s2
    case let (.openScriptInTerminal(script), .openPathInTerminal(path)):
      return script.path == path /* TODO: Equal-ish */
    case let (.openPathInTerminal(p1), .openPathInTerminal(p2)):
      return p1 == p2
    default:
      return false
    }
  }
}
