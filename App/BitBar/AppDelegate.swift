import Cocoa
import SwiftyUserDefaults

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  private var manager: PluginManager?
  func applicationDidFinishLaunching(_ aNotification: Notification) {
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
      manager = PluginManager(path: path)
    } else {
      App.askAboutPluginPath { self.loadPluginManager() }
    }
  }
}
