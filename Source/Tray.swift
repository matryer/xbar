import AppKit
import EmitterKit
import Cocoa

/**
  Represents an item in the menu bar
*/
class Tray: NSObject, NSMenuDelegate, Eventable {
  private static let center = NSStatusBar.system()
  private static let length = NSVariableStatusItemLength
  private var updatedAgoItem: UpdatedAgoItem?
  private var isOpen = false
  private var menu = NSMenu()
  private var defaultCount = 0
  var item = Tray.center.statusItem(withLength: Tray.length)
  internal weak var parentable: Eventable?

  /**
    @title A title to be displayed in the menu bar
    @isVisible Makes it possible to hide item on start up
  */
  init(title: String, isVisible displayed: Bool = false, parentable: Eventable? = nil) {
    super.init()
    set(menu: menu, parentable: parentable)
    if displayed { show() } else { hide() }
  }

  convenience init(error: String) {
    self.init(errors: [error])
  }

  convenience init(errors: [String]) {
    self.init(title: "...", isVisible: true)
    /* TODO: Pass proper error message */
    set(title: Title("errors"))
  }

  private func set(menu: NSMenu, parentable: Eventable? = nil) {
    defaultCount = menu.items.count
    self.menu = menu
    self.menu.delegate = self
    self.parentable = parentable
    item.menu = menu
    menu.autoenablesItems = false
    menu.delegate = self
    setPrefs()
    refresh()
  }

  func set(title: Title) {
    // TODO: How should be handle empty titles?
    if (title.headline?.isEmpty)! {
      item.attributedTitle = Mutable(string: "-")
    } else {
      item.attributedTitle = title.headline
    }
    set(menu: title, parentable: title)
  }

  /**
    Add @item above pref menu
  */
  func add(item: NSMenuItem) {
    menu.insertItem(item, at: max(0, menu.items.count - defaultCount))
  }

  /**
    Remove item from dropdown menu
  */
  func remove(menu item: Menu) {
    menu.removeItem(item)
  }

  /**
   Hides item from menu bar
  */
  func hide() {
    if #available(OSX 10.12, *) {
      item.isVisible = false
    } else {
      // Fallback on earlier versions
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

  private func separator() {
    menu.addItem(NSMenuItem.separator())
  }

  private func setPrefs() {
    // TODO: separator() should be static
    separator()
    updatedAgoItem = UpdatedAgoItem()
    menu.addItem(updatedAgoItem!)
    if !App.isConfigDisabled() {
      let terminal = RunInTerminal()
      terminal.parentable = self
      menu.addItem(terminal)
      menu.addItem(PrefItem())
    }
  }

  // Private, not to be called
  // Marked with 'internal' as NSMenuDelegate
  // doesn't allow for 'private'
  internal func menuWillOpen(_ menu: NSMenu) {
    updatedAgoItem?.touch()
    isOpen = true
    item.highlightMode = true
  }

  internal func menuDidClose(_ menu: NSMenu) {
    isOpen = false
    item.highlightMode = false
  }

  func didClickOpenInTerminal() {
    parentable?.didClickOpenInTerminal()
  }

  func didTriggerRefresh() {
    parentable?.didTriggerRefresh()
  }

  internal func refresh() {
    updatedAgoItem?.refresh()
  }
}
