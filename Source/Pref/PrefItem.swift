import Cocoa
import AppKit
import Sparkle
import EmitterKit

final class PrefItem: ItemBase {
  var listeners = [Listener]()

  convenience init() {
    self.init("Preferences")

    separator()
    listeners += addSub("Refresh All", key: "r", clickable: true) {
      App.didClickRefresh()
    }

    separator()

    listeners += addSub("Change Plugin Folder…", key: ",", clickable: true) {
      App.didClickChangePluginPath()
    }

    listeners += addSub("Open Plugin Folder…", clickable: true) {
      if let path = App.pluginPath {
        App.open(path: path)
      }
    }

    listeners += addSub("Get Plugins…", clickable: true) {
      App.open(url: App.website)
    }

    separator()

    listeners += addSub("Open at Login", checked: App.autostart, clickable: true) {
      /* TODO */
    //  if menu.state == NSOnState {
    //    App.update(autostart: false)
    //    menu.state = NSOffState
    //  } else {
    //    App.update(autostart: true)
    //    menu.state = NSOnState
    //  }
    }

    separator()

    listeners += addSub("Check for Updates…", clickable: true) {
      App.checkForUppdates()
    }

    listeners += addSub("Quit", key: "q", clickable: true) {
      App.didClickQuit()
    }
  }
}
