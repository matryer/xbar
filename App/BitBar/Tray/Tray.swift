import AppKit
import EmitterKit
import Cocoa
import SwiftyUserDefaults

/**
  Represents an item in the menu bar
  TODO: Remove @item from NSStatusBar.system()
    instead of using isVisible = false or hide()
*/
class Tray: NSObject, NSMenuDelegate, ItemBaseDelegate {
  private var listeners = [Listener]()
  private let openEvent = Event<Void>()
  private let closeEvent = Event<Void>()
  private let openInTerminalClickEvent = Event<Void>()
  private var isOpen = false
  private var updatedAgoItem: UpdatedAgoItem?
  private let menu = NSMenu()
  private var defaultCount = 0
  private let item: NSStatusItem = NSStatusBar.system()
    .statusItem(withLength: NSVariableStatusItemLength)
  internal weak var delegate: TrayDelegate?

  /**
    @title A title to be displayed in the menu bar
    @isVisible Makes it possible to hide item on start up
  */
  init(title: String, isVisible display: Bool = false, delegate: TrayDelegate? = nil) {
    super.init()
    self.delegate = delegate
    item.title = title
    item.menu = menu
    menu.autoenablesItems = false
    menu.delegate = self
    setPrefs()
    defaultCount = menu.items.count

    if display { show() }
  }

  func add(item: NSMenuItem) {
    let index = max(0, menu.items.count - defaultCount)
    menu.insertItem(item, at: index)
  }

  var attributedTitle: NSMutableAttributedString {
    set { item.attributedTitle = newValue }
    get {
      if let title = item.attributedTitle {
        return title.mutable()
      }

      var title = NSMutableAttributedString(string: "")
      if let aTitle = item.title {
        title = NSMutableAttributedString(string: aTitle)
      }
      item.attributedTitle = title
      return title
    }
  }

  var image: NSImage? {
    set { item.image = newValue }
    get { return item.image }
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
  deinit { destroy() }
  func destroy() {
    NSStatusBar.system().removeStatusItem(item)
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

  // func onDidClickOpenInTerminal(block: @escaping Block<Void>) {
  //   listeners.append(openInTerminalClickEvent.on(block))
  // }

  func item(didClick: ItemBase) {
     delegate?.bar(didClickOpenInTerminal: self)
  }

  private func separator() {
    item.menu?.addItem(NSMenuItem.separator())
  }

  private func setPrefs() {
    separator()
    updatedAgoItem = UpdatedAgoItem()
    item.menu?.addItem(updatedAgoItem!)
    item.menu?.addItem(ItemBase("Run in Terminal…", key: "o", delegate: self))
    item.menu?.addItem(PrefItem())
  }

  // Private, not to be called
  // Marked with 'internal' as NSMenuDelegate
  // doesn't allow for 'private'
  internal func menuWillOpen(_ menu: NSMenu) {
    updatedAgoItem?.touch()
    isOpen = true
    item.highlightMode = true
    openEvent.emit()
  }

  internal func menuDidClose(_ menu: NSMenu) {
    isOpen = false
    item.highlightMode = false
    closeEvent.emit()
  }
}
