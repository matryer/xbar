import AppKit
import EmitterKit
import DateTools
import Cocoa
import SwiftyUserDefaults
import ServiceManagement

// TODO: Move this to its own file
class Item: NSMenuItem {
  var listeners = [Listener]()
  let clickEvent = Event<Item>()

  init(_ title: String, key: String = "", block: @escaping (Item) -> Void) {
    super.init(title: title, action: #selector(didClick), keyEquivalent: key)
    target = self
    isEnabled = true
    listeners.append(clickEvent.on(block))
    attributedTitle = NSMutableAttributedString(withDefaultFont: title)
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func didClick(_ sender: NSMenu) {
    clickEvent.emit(self)
  }
}

// TODO: Use NSOpenSavePanelDelegate
class Tray: Base, NSMenuDelegate, NSOpenSavePanelDelegate {
  let item: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  weak var delegate: TrayDelegate?
  var updatedAt = NSDate()
  var listeners = [Listener]()
  let openEvent = Event<()>()
  let closeEvent = Event<()>()

  init(title: String, isVisible: Bool? = false) {
    item.title = title
    super.init()
    if isVisible! { show() }
    setMenu(NSMenu())
  }

  internal func show() {
    log("show", "Tray is being shown")
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
    item.menu?.addItem(Item("Refresh All", key: "r") {_ in
      self.delegate?.preferenceDidRefreshAll()
    })

    separator()

    item.menu?.addItem(Item("Change Plugin Folder…") {_ in
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

    item.menu?.addItem(Item("Open Plugin Folder…") {_ in
      print("Open Plugin Folder…")
    })

    item.menu?.addItem(Item("Get Plugins…") {_ in
      print("Get Plugins…")
    })

    separator()

    let login = Item("Open at Login") { menu in
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

    item.menu?.addItem(Item("Check for Updates…") {_ in
      print("Check for Updates…")
    })

    item.menu?.addItem(Item("Quit", key: "q") {_ in
      self.delegate?.preferenceDidQuit()
    })
  }

  internal func hide() {
    log("hide", "Tray is hiding")
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
}
