import AppKit
import EmitterKit
import DateTools
import Cocoa
import SwiftyUserDefaults

// TODO: Use NSOpenSavePanelDelegate
class Tray: Base, NSMenuDelegate, NSOpenSavePanelDelegate {
  let item: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  weak var delegate: TrayDelegate?
  var updatedAt = NSDate()
  var listeners = [Listener]()
  let openEvent = Event<()>()
  let closeEvent = Event<()>()
  var isOpen = false
//  let prefItem = PrefItem()

  init(title: String, isVisible: Bool? = false) {
    item.title = title
    super.init()
    if isVisible! { show() }
    setMenu(NSMenu())
    onDidOpen { self.isOpen = true }
    onDidClose { self.isOpen = false }
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
    item.menu?.addItem(ItemBase("Updated X seconds ago"))
    item.menu?.addItem(ItemBase("Run in Terminal…", key: "o") {
      self.delegate?.preferenceDidOpenInTerminal()
    })
    item.menu?.addItem(PrefItem(delegate: delegate))
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

  /**
    Display item in menu bar
  */
  internal func show() {
    if #available(OSX 10.12, *) {
      item.isVisible = true
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
