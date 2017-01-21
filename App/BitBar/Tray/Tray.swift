import AppKit
import EmitterKit
import Cocoa
import SwiftyUserDefaults

/**
  Represents an item in the menu bar
  TODO: Remove @item from NSStatusBar.system()
    instead of using isVisible = false or hide()
*/
class Tray: NSObject, NSMenuDelegate {
  private var listeners = [Listener]()
  private let openEvent = Event<Void>()
  private let closeEvent = Event<Void>()
  private var isOpen = false
  private var updatedAgoItem: UpdatedAgoItem?
  private let item: NSStatusItem = NSStatusBar.system()
    .statusItem(withLength: NSVariableStatusItemLength)
  internal weak var delegate: TrayDelegate?

  /**
    @title A title to be displayed in the menu bar
    @isVisible Makes it possible to hide item on start up
  */
  init(title: String, isVisible: Bool = true, delegate: TrayDelegate? = nil) {
    self.delegate = delegate
    super.init()

    item.title = title
    setMenu(NSMenu())

    onDidOpen {
      self.updatedAgoItem?.touch()
      self.isOpen = true
      self.item.highlightMode = true
    }

    onDidClose {
      self.isOpen = false
      self.item.highlightMode = false
    }

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

  /*
    Completely removes item from menu bar
  */
  func destroy() {
    guard !isOpen else {
      return onDidClose { self.destroy() }
    }

    NSStatusBar.system().removeStatusItem(item)
  }

  /**
    TODO: Replace with set(error: String)
    Currently being used by Plugin
  */
  func clear(title: String) {
    item.menu?.removeAllItems()
    item.title = title
  }

  /**
    @block is called every time the drop down menu bar is shown
  */
  func onDidOpen(block: @escaping () -> Void) {
    listeners.append(openEvent.on(block))
  }

  /**
    @block is called every time the drop down menu bar is hidden
  */
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

  // Private, not to be called
  // Marked with 'internal' as NSMenuDelegate
  // doesn't allow for 'private'
  internal func menuWillOpen(_ menu: NSMenu) {
    openEvent.emit()
  }

  internal func menuDidClose(_ menu: NSMenu) {
    closeEvent.emit()
  }
}
