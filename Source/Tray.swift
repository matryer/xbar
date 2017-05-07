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
  private var menu = NSMenu()
  var item: Menubarable
  static internal var item: Menubarable {
    return Tray.center.statusItem(withLength: Tray.length)
  }
  var isError = false

  /**
    @title A title to be displayed in the menu bar
    @isVisible Makes it possible to hide item on start up
  */
  init(title: String, isVisible displayed: Bool = false, item: Menubarable = Tray.item) {
    self.item = item
    super.init()
    set(headline: title.mutable)
    set(menu: menu)
    if displayed { show() } else { hide() }
  }

  convenience init(error: String) {
    self.init(errors: [error])
  }

  convenience init(errors: [String]) {
    self.init(title: "…", isVisible: true)
    set(title: Title(errors: errors))
  }

  private func set(menu: NSMenu) {
    self.menu = menu
    self.menu.delegate = self
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
    set(menu: title)
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
    item.highlightMode = true
  }

  internal func menuDidClose(_ menu: NSMenu) {
    item.highlightMode = false
  }

  func on(_ event: MenuEvent) {
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
