import Cocoa
import SwiftyUserDefaults

typealias Block<T> = (T) -> Void

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, TrayDelegate {
  private weak var manager: PluginManager?
  private let listen = Listen(NSWorkspace.shared().notificationCenter)

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    loadPluginManager()

    listen.on(.NSWorkspaceDidWake) {
      self.loadPluginManager()
    }
  }

  /**
    User choose 'Refresh All' in the menu bar
    Creating a new manager
  */
  func preferenceDidRefreshAll() {
    loadPluginManager()
  }

  /**
    User selected 'Quit' in the menu bar
  */
  func preferenceDidQuit() {
    NSApp.terminate(self)
  }

  /**
    Use changed plugin folder
  */
  func preferenceDidChangePluginFolder() {
    App.askAboutPluginPath { self.loadPluginManager() }
  }

  /**
    User clicked 'Open in Terminal' in preference menu
  */
  func preferenceDidOpenInTerminal() {
    // FIXME: Not sure AppDelegate needs this info
  }

  private func loadPluginManager() {
    manager?.destroy()
    if let path = App.pluginPath {
      manager = PluginManager(path: path, delegate: self)
    } else {
      App.askAboutPluginPath { self.loadPluginManager() }
    }
  }
}
