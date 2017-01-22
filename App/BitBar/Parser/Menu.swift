import Cocoa
import AppKit
import EmitterKit

final class Menu: ItemBase, Menuable {
  var level: Int = 0
  private var events = [Listener]()
  private let refreshEvent = Event<Void>()
  private var container = Container()

  var aTitle: NSMutableAttributedString {
    get { return currentTitle() }
    set { attributedTitle = newValue }
  }

  var params = [Param]() {
    willSet(params) {
      apply(params: params)
    }
  }
  var menus = [Menu]() {
    willSet(menus) {
      apply(menus: menus)
    }
  }

  init(_ title: String) {
    super.init(title)
  }

  convenience init(_ title: String, menus: [Menu]) {
    self.init(title)
    self.menus = menus
    self.container.delegate = self
  }

  // For testing
  convenience init(_ title: String, level: Int, menus: [Menu]) {
    self.init(title, menus: menus)
    self.level = level
  }

  convenience init(_ title: String, params: [Param]) {
    self.init(title, params: params, menus: [])
  }

  convenience init(_ title: String, parent: Menu, params: [Param]) {
    self.init(title, params: params, menus: [])
    // self.myParent = parent
    self.level = parent.level + 1
  }

  convenience init(_ title: String, params: [Param], level: Int, menus: [Menu]) {
    self.init(title, level: level, menus: menus)
    self.params = params
    apply(params: params)
  }

  convenience init(_ title: String, params: [Param], menus: [Menu]) {
    self.init(title, params: params, level: 0, menus: menus)
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
  func update(state: Int) {
    self.state = state
  }

  /* TODO: Remove */
  func getValue() -> String {
    return title
  }

  /* TODO: Remove */
  func toString() -> String {
    return getValue()
  }

  /**
    Should refresh events cascade to its parent?
    Set by the refresh=bool attribute
  */
  func shouldRefresh() -> Bool {
    return container.shouldRefresh()
  }

  /**
    Should sub menus be disabled?
    Set by the dropdown=bool attribute
  */
  func hasDropdown() -> Bool {
    return container.hasDropdown()
  }

  /**
    Should the terminal be opened when clicked?
    Set by the terminal=bool attribute
  */
  func openTerminal() -> Bool {
    return container.openTerminal()
  }

  /**
    Trigger callbacks registered via onDidRefresh
  */
  func refresh() {
    refreshEvent.emit()
  }

  /**
    @block is invoked when refresh=true and child
    menu item has finished loading
  */
  func onDidRefresh(block: @escaping () -> Void) {
    events.append(refreshEvent.on(block))
  }

  /* TODO: Rename */
  func getAttrs() -> NSMutableAttributedString {
    return currentTitle()
  }

  /* TODO: Rename */
  func getArgs() -> [String] {
    return container.args
  }

  /* TODO: Remove */
  func getTitle() -> String {
    return title
  }

  /**
    Menus starting with a dash "-" are considered separators
  */
  func isSeparator() -> Bool {
    return title.strip() == "-"
  }

  private func currentTitle() -> NSMutableAttributedString {
    guard let title = attributedTitle else {
      return NSMutableAttributedString(withDefaultFont: "")
    }

    return title.mutable()
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func apply(menus: [Menu]) {
    guard hasDropdown() else {
      return removeAllSubMenus()
    }

    for menu in menus {
      if menu.isSeparator() {
        addSub(NSMenuItem.separator())
      } else {
        addSub(menu)
      }
    }
  }

  private func apply(params: [Param]) {
    container.append(params: params)
    container.apply()
  }
}
