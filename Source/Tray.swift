import AppKit
import EmitterKit
import Cocoa

/**
  Represents an item in the menu bar
*/


class Tray: NSObject, NSMenuDelegate, Titlable {
  var warningLabel = barWarn
  var textFont = barFont
  internal weak var root: Parent?
  internal var originalTitle: NSAttributedString?
  private static let center = NSStatusBar.system()
  private static let length = NSVariableStatusItemLength
  private var ago: Pref.UpdatedTimeAgo?
  private var menu = NSMenu()
  private var item: MenuBar
  static internal var item: MenuBar {
    return Tray.center.statusItem(withLength: Tray.length)
  }
  var attributedTitle: NSAttributedString? {
    get { return item.attributedTitle }
    set { item.attributedTitle = newValue }
  }

  /**
    @title A title to be displayed in the menu bar
    @isVisible Makes it possible to hide item on start up
  */
  init(title: String, isVisible displayed: Bool = false, item: MenuBar = Tray.item) {
    self.item = item
    super.init()
    set(menu: menu)
    set(title: title)
    if displayed { show() } else { hide() }
  }

  convenience init(error: String) {
    self.init(errors: [error])
  }

  convenience init(errors: [String]) {
    self.init(title: "…", isVisible: true)
    set(title: Title(errors: errors))
  }

  func set(title: Title) {
    set(menu: title)
    if let aTitle = title.headline {
      set(title: aTitle)
    } else {
      set(title: "…")
    }
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

  private func set(menu: NSMenu) {
    self.menu = menu
    self.menu.delegate = self
    item.menu = menu
    menu.autoenablesItems = false
    menu.delegate = self
    setPrefs()
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
    ago?.touch()
    item.highlightMode = true
  }

  internal func menuDidClose(_ menu: NSMenu) {
    item.highlightMode = false
  }

  func on(_ event: MenuEvent) {
    switch event {
    case .didSetError:
      set(error: true)
    default:
      break
    }
  }
}
