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
    item.menu?.addItem(ItemBase("Refresh All", key: "r") {
      self.delegate?.preferenceDidRefreshAll()
    })

    separator()

    item.menu?.addItem(ItemBase("Change Plugin Folder…") {
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
    })

    item.menu?.addItem(ItemBase("Open Plugin Folder…") {
      print("Open Plugin Folder…")
    })

    item.menu?.addItem(ItemBase("Get Plugins…") {
      print("Get Plugins…")
    })

    separator()

    let login = ItemBase("Open at Login") { (menu: ItemBase) in
      let current = Bundle.main

      guard let id = current.bundleIdentifier else {
        return print("No id found")
      }

      SMLoginItemSetEnabled(id as CFString, menu.state == NSOnState)
      Defaults[.startAtLogin] = menu.state == NSOnState
    }

    item.menu?.addItem(login)
    if let isLog = Defaults[.startAtLogin] {
      if isLog {
        login.state = NSOnState
      }
    }

    separator()

    item.menu?.addItem(ItemBase("Check for Updates…") {
      print("Check for Updates…")
    })

    item.menu?.addItem(ItemBase("Quit", key: "q") {
      self.delegate?.preferenceDidQuit()
    })
  }

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

  @objc internal func onDidClickMenu() {
    log("onDidClickMenu", "Clicked menu button")
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
