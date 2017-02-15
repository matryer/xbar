import SwiftyUserDefaults
import Foundation
import EmitterKit
typealias Block<T> = (T) -> Void

/**
  Global values and helpers
*/
class App {
  /**
    Event listeners
  */

  /**
    @block is invoked when the user clicks "Quit" in
    the preference menu or uses the defined shortcut
  */
  static func onDidClickQuit(block: @escaping Block<Void>) {
    listeners.append(quitEvent.on(block))
  }

  /**
    @block is invoked when the user clicks "Change plugin path" in
    the preference menu or uses the defined shortcut
  */
  static func onDidClickChangePluginPath(block: @escaping Block<Void>) {
    listeners.append(changePathEvent.on(block))
  }

  /**
    @block is invoked when the user clicks "Refresh All" in
    the preference menu or uses the defined shortcut
  */
  static func onDidClickRefresh(block: @escaping Block<Void>) {
    listeners.append(refreshEvent.on(block))
  }

  /**
    @block is invoked when the system wakes up from sleep
  */
  static func onDidWake(block: @escaping Block<Void>) {
    gListeners.append(listen.on(.NSWorkspaceDidWake, block: block))
  }

  static var updatePath: URL {
    // TODO: "https://bitbarapp.com/feeds/bitbar"
    return URL(string: "https://bitbarapp.com/feeds/bitbar")!
  }

  /**
    Event triggers
  */

  /**
    Triggers the onDidClickQuit event
    Used by the Tray to signal events back the AppDelegate
  */
  static func didClickQuit() {
    quitEvent.emit()
  }

  /**
    Triggers the onDidClickChangePluginPath event
    Used by the Tray to signal events back the AppDelegate
  */
  static func didClickChangePluginPath() {
    changePathEvent.emit()
  }

  /**
    Triggers the onDidClickRefresh event
    Used by the Tray to signal events back the AppDelegate
  */
  static func didClickRefresh() {
    refreshEvent.emit()
  }

  /**
    Bundle id for current application, i.e com.getbitbar
  */
  static var id: CFString {
    return currentBundle.bundleIdentifier! as CFString
  }

  /**
    Absolut path to the resource path
  */
  static var resourcePath: String {
    return currentBundle.resourcePath!
  }

  /**
    URL to project page
  */
  static var website: URL {
    return URL(string: "https://getbitbar.com/")!
  }

  /**
    Absolute URL to plugins folder
  */
  static var pluginURL: URL? {
    if let path = pluginPath {
      return NSURL(string: path) as URL?
    }

    return nil
  }

  /**
    Absolute path to plugins folder
  */
  static var pluginPath: String? {
    // TODO: This is only temp.
    // Prevent test suit to load test path
    if isInTestMode() { return nil }
    return Defaults[.pluginPath]
  }

  /**
    Does the application start at login?
  */
  static var autostart: Bool {
    return Defaults[.startAtLogin] ?? false
  }

  /**
    Open @url in browser
  */
  static func open(url: URL) {
    NSWorkspace.shared().open(url)
  }

  /**
    Open @path in Finder
  */
  static func open(path: String) {
    NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: path)
  }

  /**
    Update absolute path to plugin folder
  */
  static func update(pluginPath: String?) {
    guard let path = pluginPath else {
      return Defaults.remove(.pluginPath)
    }

    Defaults[.pluginPath] = path
  }

  /**
    Update wherever the application should start at login or not
  */
  static func update(autostart: Bool) {
    Defaults[.startAtLogin] = autostart
    if autostart { AutoLogin.on() } else { AutoLogin.off() }
  }

  static func checkForUppdates() {
    updater.check()
  }

  /**
    Retrieve the absolute path for a resource
    I.e App.path(forResource: "sub.1m.sh")
  */
  static func path(forResource path: String) -> String {
    return NSString.path(withComponents: [resourcePath, path])
  }

  static func isConfigDisabled() -> Bool {
    return Defaults[.disabled] ?? false
  }

  /**
    Invoke @block if user selects a folder
    The selected folder is stored for the future
    NOTE: @block isn't called if no folder is selected or if the dialog was closed
    TODO: @block should always be called
  */
  static func askAboutPluginPath(block: @escaping Block<Void>) {
    if App.isInTestMode() { return }
    PathSelector(withURL: App.pluginURL).ask {
      App.update(pluginPath: $0?.path)
      block()
    }
  }

  /**
    Is this a test? Used by the Tray class to
    prevent the menu bar from flickering during testing
  */
  static func isInTestMode() -> Bool {
    return ProcessInfo.processInfo.environment["XCInjectBundleInto"] != nil
  }

  static func isTravis() -> Bool {
    return ProcessInfo.processInfo.environment["TRAVIS"] != nil
  }

  private static let currentBundle = Bundle.main
  private static let quitEvent = Event<Void>()
  private static let changePathEvent = Event<Void>()
  private static let refreshEvent = Event<Void>()
  private static var listeners = [Listener]()
  private static var gListeners = [GEvent]()
  private static let listen = Listen(NSWorkspace.shared().notificationCenter)
  private static let updater = Updater()
}

func puts(_ args: Any...) {
  print("warning: ", args.map { String(describing: $0) }.joined(separator: " ").replace("\n", "[nl]"))
}

func halt(_ message: String) {
  preconditionFailure(message)
}
