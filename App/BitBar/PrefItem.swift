import Cocoa
import SwiftyUserDefaults
import ServiceManagement
import AppKit
import EmitterKit

final class PrefItem: ItemBase {
  weak var delegate: TrayDelegate?

  convenience init(delegate: TrayDelegate?) {
    self.init("Preferences")
    self.delegate = delegate

    separator()
    addSub("Refresh All", key: "r") {
      self.delegate?.preferenceDidRefreshAll()
    }

    separator()

    addSub("Change Plugin Folder…") {
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

    addSub("Open Plugin Folder…") {
      if let path = Defaults[.pluginPath] {
        NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: path)
      }
    }

    addSub("Get Plugins…") {
      if let url = URL(string: "https://getbitbar.com/") {
        NSWorkspace.shared().open(url)
      }
    }

    separator()

    addSub("Open at Login", checked: startAtLogin()) { (menu: ItemBase) in
      let current = Bundle.main

      guard let id = current.bundleIdentifier else {
        return print("No id found")
      }

      SMLoginItemSetEnabled(id as CFString, menu.state == NSOnState)
      Defaults[.startAtLogin] = menu.state == NSOnState
    }

    separator()

    addSub("Check for Updates…") {
      print("Check for Updates…")
    }

    addSub("Quit", key: "q") {
      self.delegate?.preferenceDidQuit()
    }
  }

  private func startAtLogin() -> Bool {
    return Defaults[.startAtLogin] ?? false
  }
}
