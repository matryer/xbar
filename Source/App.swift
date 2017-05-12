import Foundation
import Async
import SwiftyUserDefaults
import EmitterKit

/**
  Global values and helpers
*/
class App {
  /**
    Event triggers
  */

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

  static func open(url: String) {
    open(url: URL(string: url)!)
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
  */
  static func askAboutPluginPath(block: @escaping Block<Void>) {
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

  static func openScript(inTerminal path: String, block: @escaping (String?) -> Void) {
    let tell = [
      "tell application \"Terminal\" \n",
      "do script \"\(path.replace(" ", "\\ "))\" \n",
      "activate \n",
      "end tell"
    ].joined()

    Async.background {
      guard let script = NSAppleScript(source: tell) else {
        return "Could not parse script: \(tell)"
      }

      let errors = script.executeAndReturnError(nil)
      guard errors.numberOfItems == 0 else {
        return "Received errors when running script \(errors)"
      }

      return nil
    }.main(block)
  }

  private static let currentBundle = Bundle.main
  private static let quitEvent = Event<Void>()
  private static let changePathEvent = Event<Void>()
  private static let refreshEvent = Event<Void>()
  private static var listeners = [Listener]()
}
