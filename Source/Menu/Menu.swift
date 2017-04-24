import Cocoa
import AppKit
import EmitterKit

final class Menu: ItemBase, Menuable {
  var settings: [String : Bool] = [String: Bool]()
  var listener: Listener?
  internal var level: Int = 0
  internal var params = [Line]()
  internal weak var parentable: Menuable?
  internal var event = Event<Void>()
  internal var items: [NSMenuItem] {
    return submenu?.items ?? [NSMenuItem]()
  }
  var headline: Mutable {
    get { return attributedTitle?.mutable() ?? Mutable() }
    set { attributedTitle = newValue }
  }
  /**
    Should the terminal be opened when clicked?
    Set by the terminal=bool attribute
  */
  var openInTerminal: Bool {
    guard let terminal = (lines.first { $0 is Terminal }) else {
      return false
    }

    return terminal.original == "true"
  }

  var isChecked: Bool {
    return state == NSOnState
  }

  var isAltAlternate: Bool {
    return isAlternate && keyEquivalentModifierMask == NSAlternateKeyMask
  }

  init(_ title: String, params: [Line] = [Line](), menus: [Menu] = [], level: Int = 0) {
    self.level = level
    self.params = params
    super.init(title)
    add(menus: menus)
  }

  /**
    @error One error to be displayed in the sub menu
  */
  convenience init(error: String) {
    self.init(errors: [error])
  }

  /**
    @errors A list of errors to be displayed in the sub menu
  */
  convenience init(errors: [String]) {
    self.init(":warning: ".emojifyed(), menus: errors.map(Menu.init))
  }

  /**
    @title A title to be displayed as an item in a menu bar
    @params Parameters read and parsed from stdin, i.e terminal=false
    @menus Sub menus for this item
    @level The number of levels down from the tray
  */
  convenience init(isSeparator: Bool) {
    self.init("-")
    isHidden = true
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func submenu(didTriggerRefresh menu: Menuable) {
    parentable?.submenu(didTriggerRefresh: menu)
  }

  func refresh() {
    App.notify(.menuTriggeredRefresh)
    parentable?.submenu(didTriggerRefresh: self)
  }

  /**
    Use @self as alternativ item
  */
  func useAsAlternate() {
    isAlternate = true
    keyEquivalentModifierMask = NSAlternateKeyMask
  }

  /**
    @state Used to turn the checkbox marker on/off
  */
  func set(state: Int) {
    self.state = state
  }

  /**
    Menus starting with a dash "-" are considered separators
  */
  func isSeparator() -> Bool {
    return title.trim() == "-"
  }

  func hideDropdown() {
    removeAllSubMenus()
    deactivate()
  }
}
