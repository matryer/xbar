import Cocoa
import AppKit
import EmitterKit

final class Menu: ItemBase, Menuable {
  var settings: [String : Bool] = [String: Bool]()
  var listener: Listener?
  var args = [String]()
  internal var level: Int = 0
  internal var params = [Paramable]()
  internal weak var parentable: Menuable?
  internal var event = Event<Void>()
  internal var items: [NSMenuItem] {
    return submenu?.items ?? [NSMenuItem]()
  }
  var headline: Mutable {
    get { return currentTitle() }
    set { attributedTitle = newValue }
  }

  /**
    @title A title to be displayed as an item in a menu bar
    @params Parameters read and parsed from stdin, i.e terminal=false
    @menus Sub menus for this item
    @level The number of levels down from the tray
  */
  init(_ title: String, params: [Paramable] = [Paramable](), menus: [Menu] = [], level: Int = 0) {
    self.level = level
    self.params = params
    super.init(title)
    load()

    if shouldTrim() {
      set(headline: headline.trimmed())
    }
    add(menus: menus)
  }

  convenience init(isSeparator: Bool) {
    self.init("-")
    isHidden = true
  }

  /**
    Same as above, but derives the @level from a @parent
  */
  convenience init(_ title: String, params: [Paramable], menus: [Menu] = [], parent: Menuable) {
    self.init(title, params: params, menus: menus, level: parent.level + 1)
  }

  func submenu(didTriggerRefresh menu: Menuable) {
    parentable?.submenu(didTriggerRefresh: menu)
  }

  func refresh() {
    parentable?.submenu(didTriggerRefresh: self)
  }

  var isChecked: Bool {
    return state == NSOnState
  }

  /**
    Use @self as alternativ item
  */
  func useAsAlternate() {
    isAlternate = true
    keyEquivalentModifierMask = NSAlternateKeyMask
  }

  var isAltAlternate: Bool {
    return isAlternate && keyEquivalentModifierMask == NSAlternateKeyMask
  }

  /**
    @state Used to turn the checkbox marker on/off
  */
  func set(state: Int) {
    self.state = state
  }

  /**
    Should refresh events cascade to its parent?
    Set by the refresh=bool attribute
  */
  func shouldRefresh() -> Bool {
    return settings["refresh"] ?? true
  }

  /**
    Should sub menus be disabled?
    Set by the dropdown=bool attribute
  */
  var hasDropdown: Bool {
    return settings["dropdown"] ?? true
  }

  /**
    Should the terminal be opened when clicked?
    Set by the terminal=bool attribute
  */
  func openTerminal() -> Bool {
    return settings["terminal"] ?? true
  }

  /**
    Menus starting with a dash "-" are considered separators
  */
  func isSeparator() -> Bool {
    return title.trim() == "-"
  }

  // TODO: Remove
  private func currentTitle() -> Mutable {
    guard let title = attributedTitle else {
      return Mutable(withDefaultFont: self.title)
    }

    return title.mutable()
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
