import AppKit
import EmitterKit
import DateTools
import Cocoa
import SwiftyUserDefaults
import ServiceManagement

// TODO: Use NSOpenSavePanelDelegate
class Tray: Base, NSMenuDelegate, NSOpenSavePanelDelegate {
  let item: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  weak var delegate: TrayDelegate?
  var updatedAt = NSDate()
  var listeners = [Listener]()
  let openEvent = Event<()>()
  let closeEvent = Event<()>()
  var isOpen = false

  init(title: String, isVisible: Bool? = false) {
    item.title = title
    item.highlightMode = true
    super.init()
    if isVisible! { show() }
    setMenu(NSMenu())
    onDidOpen { self.isOpen = true }
    onDidClose { self.isOpen = false }
  }

  internal func show() {
    if #available(OSX 10.12, *) {
      item.isVisible = true
    } else {
      // TODO: Fallback on earlier versions
    }
  }

  func setMenu(_ menu: NSMenu) {
    item.menu = menu
    menu.delegate = self
    setPrefs()
  }

  private func separator() {
    item.menu?.addItem(NSMenuItem.separator())
  }

  private func setPrefs() {
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
    item.menu?.addItem(menu)
  }

  /**
   Hides item from menu bar
  */
  internal func hide() {
    if #available(OSX 10.12, *) {
      item.isVisible = false
    } else {
      // TODO: Fallback on earlier versions
    }
  }

  internal func clear(title: String) {
    item.menu?.removeAllItems()
    item.title = title
  }

  // TODO: Use
  private func getUpdatedWhen() -> String {
    return "Updated " + updatedAt.timeAgoSinceNow()
  }

  internal func menuWillOpen(_ menu: NSMenu) {
    openEvent.emit()
  }

  internal func menuDidClose(_ menu: NSMenu) {
    closeEvent.emit()
  }

  internal func onDidOpen(block: @escaping () -> Void) {
    listeners.append(openEvent.on(block))
  }

  internal func onDidClose(block: @escaping () -> Void) {
    listeners.append(closeEvent.on(block))
  }
}
