import AppKit
import EmitterKit
import Cocoa

/**
  Represents an item in the menu bar
*/
class Tray: NSObject, NSMenuDelegate, Parent {
  weak var root: Parent?
  private static let center = NSStatusBar.system()
  private static let length = NSVariableStatusItemLength
  private var ago: Pref.UpdatedTimeAgo?
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
    // TODO
   set(menu: title, parentable: nil)
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
    // TODO
//    menu.removeItem(item)
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

  private func add(sub: NSMenuItem) {
    sub.root = self
    menu.addItem(sub)
  }

  private func setPrefs() {
    ago = Pref.UpdatedTimeAgo()
    add(sub: NSMenuItem.separator())
    add(sub: ago!)
    add(sub: Pref.RunInTerminal())
    add(sub: Pref.Preferences())
  }

  internal func menuWillOpen(_ menu: NSMenu) {
    refresh()
    isOpen = true
    item.highlightMode = true
  }

  internal func menuDidClose(_ menu: NSMenu) {
    isOpen = false
    item.highlightMode = false
  }

  func on(_ event: MenuEvent) {
    print("event: \(event) in tray")
    if isError { return }
    switch event {
    case .didSetError:
      if let title = item.attributedTitle {
        let newTitle = "(:warning:) ".emojified.mutable
        newTitle.append(title)
        set(headline: newTitle)
      } else {
        preconditionFailure("[Bug] Title not set, invalid state")
      }

      isError = true
    default:
      break
    }
  }

  internal func refresh() {
    ago?.touch()
  }
}
