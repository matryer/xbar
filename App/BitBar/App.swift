import SwiftyUserDefaults
import ServiceManagement
import Foundation

/**
  Global values and helpers
*/
class App {
  private static let currentBundle = Bundle.main

  /**
    Bundle id for current application, i.e com.getbitbar.OSX
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
      return NSURL(string: path) as? URL
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
    // FIXME: Doesn't work right now
    // Use logic from old application
    // launchAtLoginController.launchAtLogin = !launchAtLoginController.launchAtLogin
    SMLoginItemSetEnabled(App.id, autostart)
    Defaults[.startAtLogin] = autostart
  }

  /**
    Retrieve the absolute path for a resource
    I.e App.path(forResource: "sub.1m.sh")
  */
  static func path(forResource path: String) -> String {
    return NSString.path(withComponents: [resourcePath, path])
  }

  /**
    Invoke @block if user selects a folder
    The selected folder is stored for the future
    NOTE: @block isn't called if no folder is selected or if the dialog was closed
    TODO: @block should always be called
  */
  static func askAboutPluginPath(block: @escaping Block<Void>) {
    PathSelector(withURL: App.pluginURL).ask {
      App.update(pluginPath: $0.path)
      block()
    }
  }
}
