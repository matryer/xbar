import Cocoa
import AppKit
import Sparkle
import EmitterKit

final class PrefItem: ItemBase {
  convenience init() {
    self.init("Preferences")

    separator()
    addSub("Refresh All", key: "r") {
      App.didClickRefresh()
    }

    separator()

    addSub("Change Plugin Folder…", key: ",") {
      App.didClickChangePluginPath()
    }

    addSub("Open Plugin Folder…") {
      if let path = App.pluginPath {
        App.open(path: path)
      }
    }

    addSub("Get Plugins…") {
      App.open(url: App.website)
    }

    separator()

    addSub("Open at Login", checked: App.autostart) { (menu: ItemBase) in
      if menu.state == NSOnState {
        App.update(autostart: false)
        menu.state = NSOffState
      } else {
        App.update(autostart: true)
        menu.state = NSOnState
      }
    }

    separator()

    addSub("Check for Updates…") {
      App.checkForUppdates()
    }

    addSub("Quit", key: "q") {
      App.didClickQuit()
    }
  }
}
