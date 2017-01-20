import Cocoa
import SwiftyUserDefaults
import ServiceManagement
import AppKit
import EmitterKit

final class PrefItem: ItemBase {
  weak var delegate: TrayDelegate?

  convenience init(delegate: TrayDelegate?) {
    self.init("Preferences")
    self.submenu = NSMenu()
    self.delegate = delegate

    separator()
    sub("Refresh All", key: "r") {
      self.delegate?.preferenceDidRefreshAll()
    }

    separator()

    sub("Change Plugin Folder…") {
      let openPanel = NSOpenPanel()
      openPanel.allowsMultipleSelection = false
      openPanel.prompt = "Use as Plugins Directory"
      if let pluginPath = Defaults[.pluginPath] {
        if let url = NSURL(string: pluginPath) {
          openPanel.directoryURL = url as URL
        }
      }
      openPanel.canChooseDirectories = true
      openPanel.canCreateDirectories = false
      openPanel.canChooseFiles = false
      if openPanel.runModal() == NSModalResponseOK {
        if let path = openPanel.url?.path {
          Defaults[.pluginPath] = path
          self.delegate?.preferenceDidChangePluginFolder()
        }
      }
    }

    sub("Open Plugin Folder…") {
      if let path = Defaults[.pluginPath] {
        NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: path)
      }
    }

    sub("Get Plugins…") {
      if let url = URL(string: "https://getbitbar.com/") {
        NSWorkspace.shared().open(url)
      }
    }

    separator()

    sub("Open at Login", checked: startAtLogin()) { (menu: ItemBase) in
      let current = Bundle.main

      guard let id = current.bundleIdentifier else {
        return print("No id found")
      }

      SMLoginItemSetEnabled(id as CFString, menu.state == NSOnState)
      Defaults[.startAtLogin] = menu.state == NSOnState
    }

    separator()

    sub("Check for Updates…") {
      print("Check for Updates…")
    }

    sub("Quit", key: "q") {
      self.delegate?.preferenceDidQuit()
    }
  }

  private func startAtLogin() -> Bool {
    return Defaults[.startAtLogin] ?? false
  }

  private func sub(_ name: String, checked: Bool = false, key: String = "", block: @escaping () -> Void) {
    sub(name, checked: checked, key: key) { (_:ItemBase) in block() }
  }

  private func sub(_ name: String, checked: Bool = false, key: String = "", block: @escaping (ItemBase) -> Void) {
    let menu = ItemBase(name, key: key) { item in block(item) }
    menu.state = checked ? NSOnState : NSOffState
    submenu?.addItem(menu)
  }

  private func separator() {
    submenu?.addItem(NSMenuItem.separator())
  }
}
