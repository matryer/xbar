import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  private var manager: PluginManager?
  func applicationDidFinishLaunching(_: Notification) {
    loadPluginManager()

    App.onDidWake {
      self.loadPluginManager()
    }

    App.onDidClickQuit {
      NSApp.terminate(self)
    }

    App.onDidClickChangePluginPath {
      App.askAboutPluginPath {
        self.loadPluginManager()
      }
    }

    App.onDidClickRefresh {
      self.loadPluginManager()
    }
  }

  private func loadPluginManager() {
    if let path = App.pluginPath {
      return loadManager(fromPath: path)
    }

    App.askAboutPluginPath {
      self.loadPluginManager()
    }
  }

  private func loadManager(fromPath path: String) {
    manager = PluginManager(path: path)
  }
}
