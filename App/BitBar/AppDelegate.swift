import Cocoa
import SwiftyUserDefaults

// TODO: Use everywhere
typealias Block<T> = () -> T

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, TrayDelegate {
  var manager: PluginManager?
  let center = NSWorkspace.shared().notificationCenter
  let name = Notification.Name.NSWorkspaceDidWake

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    loadPluginManager()
    center.addObserver(
      self,
      selector: #selector(AppDelegate.applicationDidWakeup),
      name: name,
      object: nil
    )
  }

  /**
    Application woke up from sleep
    Creating a new manager
  */
  public func applicationDidWakeup() {
    loadPluginManager()
  }

  /**
    User choose 'Refresh All' in the menu bar
    Creating a new manager
  */
  internal func preferenceDidRefreshAll() {
    loadPluginManager()
  }

  /**
    User selected 'Quit' in the menu bar
  */
  internal func preferenceDidQuit() {
    NSApp.terminate(self)
  }

  /**
    Use changed plugin folder
  */
  internal func preferenceDidChangePluginFolder() {
    loadPluginManager()
  }

  /**
    User clicked 'Open in Terminal' in preference menu
  */
  internal func preferenceDidOpenInTerminal() {
  }

  private func loadPluginManager() {
    manager?.quit()
    if let pluginPath = Defaults[.pluginPath] {
      manager = PluginManager(path: pluginPath, delegate: self)
    }
  }

  private func log(_ org: String, _ message: String) {
    print("[LOG]", org, message)
  }
}
