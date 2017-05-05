import AppKit
import EmitterKit
import Cocoa

protocol Menubarable {
  var menu: NSMenu? { get set }
  var attributedTitle: NSAttributedString? { get set }
  var highlightMode: Bool { get set }
  func show()
  func hide()
}

extension NSStatusItem: Menubarable {
  func show() {
    if #available(OSX 10.12, *) {
      isVisible = true
    }
  }

  func hide() {
    if #available(OSX 10.12, *) {
      isVisible = false
    }
  }
}

class TestBar: Menubarable {
  var menu: NSMenu?
  var attributedTitle: NSAttributedString?
  var highlightMode: Bool = false
  func show() {}
  func hide() {}
}

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
  var item: Menubarable
  internal weak var parentable: Eventable?
  static internal var item: Menubarable {
    return Tray.center.statusItem(withLength: Tray.length)
  }
  var isError = false

  /**
    @title A title to be displayed in the menu bar
    @isVisible Makes it possible to hide item on start up
  */
  init(title: String, isVisible displayed: Bool = false, parentable: Eventable? = nil, item: Menubarable = Tray.item) {
    self.item = item
    super.init()
    set(headline: title.mutable)
    set(menu: menu, parentable: parentable)
    if displayed { show() } else { hide() }
  }

  convenience init(error: String) {
    self.init(errors: [error])
  }

  convenience init(errors: [String]) {
    self.init(title: "…", isVisible: true)
    set(title: Title(errors: errors))
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

  func set(headline: NSAttributedString) {
    isError = false
    item.attributedTitle = headline
  }

  func set(title: Title) {
    set(headline: title.headline ?? "-".mutable)
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
    item.hide()
  }

  /**
    Display item in menu bar
  */
  func show() {
    item.show()
  }

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

  func didSetError() {
    if isError { return }
    if let title = item.attributedTitle {
      let newTitle = "(:warning:) ".emojified.mutable
      newTitle.append(title)
      set(headline: newTitle)
    } else {
      preconditionFailure("[Bug] Title not set, invalid state")
    }

    isError = true
  }

  internal func refresh() {
    updatedAgoItem?.refresh()
  }
}
