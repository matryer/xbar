import AppKit
import EmitterKit
import Cocoa

/**
  Represents an item in the menu bar
  TODO: Remove @item from NSStatusBar.system()
    instead of using isVisible = false or hide()
*/
class Tray: NSObject, NSMenuDelegate, ItemBaseDelegate {
  private static let center = NSStatusBar.system()
  private static let length = NSVariableStatusItemLength

  private var updatedAgoItem: UpdatedAgoItem?
  private var listeners = [Listener]()
  private let openEvent = Event<Void>()
  private let closeEvent = Event<Void>()
  private let openInTerminalClickEvent = Event<Void>()
  private var isOpen = false
  private let menu = NSMenu()
  private var defaultCount = 0
  private let item = Tray.center.statusItem(withLength: Tray.length)
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
    menu.insertItem(item, at: max(0, menu.items.count - defaultCount))
  }

  var attributedTitle: Mutable {
    set { item.attributedTitle = newValue }
    get {
      if let title = item.attributedTitle {
        return title.mutable()
      }

      if let title = item.title {
        return Mutable(string: title)
      }

      return Mutable(string: "")
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
  func destroy() {
    Tray.center.removeStatusItem(item)
  }
  deinit { destroy() }

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

  func item(didClick: ItemBase) {
     delegate?.bar(didClickOpenInTerminal: self)
  }

  private func separator() {
    menu.addItem(NSMenuItem.separator())
  }

  private func setPrefs() {
    // TODO: These should be static
    separator()
    updatedAgoItem = UpdatedAgoItem()
    menu.addItem(updatedAgoItem!)
    menu.addItem(ItemBase("Run in Terminal…", key: "o", delegate: self))
    menu.addItem(PrefItem())
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
