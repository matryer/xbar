import Cocoa
import AppKit
import Sparkle
import EmitterKit

final class PrefItem: ItemBase {
  convenience init() {
    self.init("Preferences")

    separator()
    addSub("Refresh All", key: "r", clickable: true) {
      App.didClickRefresh()
    }

    separator()

    addSub("Change Plugin Folder…", key: ",", clickable: true) {
      App.didClickChangePluginPath()
    }

    addSub("Open Plugin Folder…", clickable: true) {
      if let path = App.pluginPath {
        App.open(path: path)
      }
    }

    addSub("Get Plugins…", clickable: true) {
      App.open(url: App.website)
    }

    separator()

    addSub("Open at Login", checked: App.autostart, clickable: true) { (menu: ItemBase) in
      if menu.state == NSOnState {
        App.update(autostart: false)
        menu.state = NSOffState
      } else {
        App.update(autostart: true)
        menu.state = NSOnState
      }
    }

    separator()

    addSub("Check for Updates…", clickable: true) {
      App.checkForUppdates()
    }

    addSub("Quit", key: "q", clickable: true) {
      App.didClickQuit()
    }
  }
}
