import Cocoa
import AppKit
import EmitterKit

final class Menu: ItemBase, MenuDelegate {
  var level: Int = 0
  var params: [Param] = []
  var menus: [Menu] = []
  var _params: [Param] = []
  var count: Int = 0
  var font: NSFont?
  var events = [Listener]()
  let refreshEvent = Event<()>()

  convenience init(_ title: String, menus: [Menu]) {
    self.init(title)
    self.menus = menus
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

  convenience init(_ title: String, params: [Param], menus: [Menu]) {
    self.init(title, params: params, level: 0, menus: menus)
  }

  convenience init(_ title: String, params: [Param], level: Int, menus: [Menu]) {
    self.init(title, level: level, menus: menus)
    // TODO: Prioritize params better then this
    let _paramsSort = params.sorted { p1, _ in
      return p1 is Ansi
    }

    for param in _paramsSort {
      switch param {
      case is NamedParam:
        self.params.append(param)
      default:
        _params.append(param)
      }
    }
  }

  internal func useAsAlternate() {
    isAlternate = true
    keyEquivalentModifierMask = NSAlternateKeyMask
  }

  internal func update(attr: NSMutableAttributedString) {
    set(title: currentTitle().merge(attr))
  }

  internal func update(color: NSColor) {
    set(title: currentTitle().update(attr: [NSForegroundColorAttributeName: color]))
  }

  internal func update(title: String) {
    update(attr: NSMutableAttributedString(string: title))
  }

  internal func update(state: Int) {
    self.state = state
  }

  internal func update(fontName: String) {
    set(title: currentTitle().update(fontName: fontName))
  }

  internal func update(image: NSImage, isTemplate: Bool = false) {
    self.image = image
    self.image?.isTemplate = isTemplate
  }

  internal func update(size: Float) {
    set(title: currentTitle().update(fontSize: size))
  }

  internal func getValue() -> String {
    return title
  }

  internal func toString() -> String {
    return getValue()
  }

  internal func apply() {
    guard hasDropdown() else {
      return
    }

    events = []
    for param in _params {
      param.applyTo(menu: self)
    }

    for menu in menus {
      menu.apply()
    }

    for menu in menus {
      if menu.isSeparator() {
        addSub(NSMenuItem.separator())
      } else {
        addSub(menu)
      }
    }
  }

  internal func shouldRefresh() -> Bool {
    return _params.reduce(false) {
      if let refresh = $1 as? Refresh {
        return $0 || refresh.getValue()
      }

      return $0
    }
  }

  internal func hasDropdown() -> Bool {
    for param in _params {
      if let dropdown = param as? Dropdown {
        return dropdown.getValue()
      }
    }

    return true
  }

  internal func openTerminal() -> Bool {
    return _params.reduce(false) {
      if let terminal = $1 as? Terminal {
        return $0 || terminal.getValue()
      }

      return $0
    }
  }

  internal func refresh() {
    refreshEvent.emit()
  }

  internal func onDidRefresh(block: @escaping () -> Void) {
    events.append(refreshEvent.on(block))
  }

  internal func getAttrs() -> NSMutableAttributedString {
    return currentTitle()
  }

  internal func getArgs() -> [String] {
    // TODO: Check that the indexes are consecutive
    return params.sorted {
      guard let param1 = $0 as? NamedParam else {
        return false
      }

      guard let param2 = $1 as? NamedParam else {
        return false
      }

      return param1.getIndex() < param2.getIndex()
    }.reduce([]) {
      if let param = $1 as? NamedParam {
        return $0 + [param.getValue()]
      }

      return $0
    }
  }

  internal func getTitle() -> String {
    return title
  }

  /**
    Menus starting with a dash "-" are considered separators
  */
  internal func isSeparator() -> Bool {
    return title.strip() == "-"
  }

  private func set(title: NSMutableAttributedString) {
    attributedTitle = title
  }

  private func update(key: String, value: Any) {
    set(title: currentTitle().update(attr: [key: value]))
  }

  private func currentTitle() -> NSMutableAttributedString {
    guard let title = attributedTitle else {
      return NSMutableAttributedString(withDefaultFont: "")
    }

    return title.mutable()
  }
}
