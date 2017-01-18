import AppKit
import EmitterKit
import DateTools
import SwiftyUserDefaults

// TODO: Move this to its own file
class Item: NSMenuItem {
  var listeners = [Listener]()
  let clickEvent = Event<()>()

  init(_ title: String, key: String = "", block: @escaping () -> Void) {
    super.init(title: title, action: #selector(didClick), keyEquivalent: key)
    target = self
    isEnabled = true
    listeners.append(clickEvent.on(block))
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func didClick(_ sender: NSMenu) {
    clickEvent.emit()
  }
}

// https://developer.apple.com/reference/appkit/nsopensavepaneldelegate
// https://developer.apple.com/reference/appkit/nssavepanel
// https://developer.apple.com/reference/appkit/nsopenpanel
// https://github.com/radex/SwiftyUserDefaults

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
    item.menu?.addItem(Item("Refresh All", key: "r") {
      self.delegate?.preferenceDidRefreshAll()
    })

    separator()

    item.menu?.addItem(Item("Change Plugin Folder…") {
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
        }
      }
    })

    item.menu?.addItem(Item("Open Plugin Folder…") {
      print("Open Plugin Folder…")
    })

    item.menu?.addItem(Item("Get Plugins…") {
      print("Get Plugins…")
    })

    separator()

    item.menu?.addItem(Item("Open at Login") {
      print("Open at Login")
    })

    separator()

    item.menu?.addItem(Item("Check for Updates…") {
      print("Check for Updates…")
    })

    item.menu?.addItem(Item("Quit", key: "q") {
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
