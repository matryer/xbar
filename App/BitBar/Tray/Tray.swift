import AppKit
import EmitterKit
import Cocoa
import SwiftyUserDefaults

// TODO: Use NSOpenSavePanelDelegate
class Tray: Base, NSMenuDelegate, NSOpenSavePanelDelegate {
  let item: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  weak var delegate: TrayDelegate?
  var listeners = [Listener]()
  let openEvent = Event<()>()
  let closeEvent = Event<()>()
  var isOpen = false
  var updatedAgoItem: UpdatedAgoItem?

  init(title: String, isVisible: Bool = false) {
    super.init()
    item.title = title
    setMenu(NSMenu())
    onDidOpen {
      self.updatedAgoItem?.touch()
      self.isOpen = true
    }
    onDidClose { self.isOpen = false }
    if isVisible {
      show()
    }
  }

  /**
   Hides item from menu bar
  */
  func hide() {
    if #available(OSX 10.12, *) {
      item.isVisible = false
    } else {
      // TODO: Fallback on earlier versions
    }
  }

  /**
    Display item in menu bar
  */
  func show() {
    if #available(OSX 10.12, *) {
      item.isVisible = true
    } else {
      // TODO: Fallback on earlier versions
    }
  }

  func clear(title: String) {
    item.menu?.removeAllItems()
    item.title = title
  }

  func menuWillOpen(_ menu: NSMenu) {
    openEvent.emit()
  }

  func menuDidClose(_ menu: NSMenu) {
    closeEvent.emit()
  }

  func onDidOpen(block: @escaping () -> Void) {
    listeners.append(openEvent.on(block))
  }

  func onDidClose(block: @escaping () -> Void) {
    listeners.append(closeEvent.on(block))
  }

  func setMenu(_ menu: NSMenu) {
    item.menu = menu
    menu.autoenablesItems = false
    menu.delegate = self
    setPrefs()
  }

  private func separator() {
    item.menu?.addItem(NSMenuItem.separator())
  }

  private func setPrefs() {
    separator()
    updatedAgoItem = UpdatedAgoItem()
    item.menu?.addItem(updatedAgoItem!)
    item.menu?.addItem(ItemBase("Run in Terminal…", key: "o") {
      self.delegate?.preferenceDidOpenInTerminal()
    })
    item.menu?.addItem(PrefItem(delegate: delegate))
  }
}
