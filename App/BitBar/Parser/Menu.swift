import Cocoa
import AppKit
import EmitterKit

// Inherit from Item class
final class Menu: NSMenuItem, MenuDelegate {
  var level: Int = 0
  var params: [Param] = []
  var menus: [Menu] = []
  var _params: [Param] = []
  var count: Int = 0
  var font: NSFont?
  var myParent: Menu?
  let clickEvent = Event<()>()
  var events = [Listener]()
  let refreshEvent = Event<()>()

  init(_ title: String) {
    super.init(title: title, action: #selector(didClick), keyEquivalent: "")
    target = self
    isEnabled = true
  }

  convenience init(_ title: String, menus: [Menu]) {
    self.init(title)
    self.menus = menus
    if !menus.isEmpty {
      submenu = NSMenu()
    }
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
    self.myParent = parent
    parent.submenu?.addItem(self)
    self.level = parent.level + 1
  }

  // TODO: Rename 'pp'
  convenience init(_ title: String, params pp: [Param], level: Int, menus: [Menu]) {
    self.init(title, level: level, menus: menus)

    for param in pp {
      switch param {
      case is NamedParam:
        params.append(param)
      default:
        _params.append(param)
      }
    }
  }

  func useAsAlternate() {
    isAlternate = true
    keyEquivalentModifierMask = NSAlternateKeyMask
  }

  func update(attr: NSMutableAttributedString) {
    attributedTitle = attr
  }

  convenience init(_ title: String, params: [Param], menus: [Menu]) {
    self.init(title, params: params, level: 0, menus: menus)
  }

  private func getAttr() -> [String: Any] {
    guard let attr = attributedTitle else {
      return [:]
    }

    if attr.length == 0 {
      return [:]
    }

    return attr.fontAttributes(in: NSMakeRange(0, attr.length))
  }

  func update(key: String, value: Any) {
    var attr = getAttr()
    attr[key] = value
    attributedTitle = NSAttributedString(string: title, attributes: attr)
  }

  func update(color: NSColor) {
    update(key: NSForegroundColorAttributeName, value: color)
  }

  func update(title: String) {
    update(attr: NSMutableAttributedString(string: title))
  }

  func update(state: Int) {
    self.state = state
  }

  func update(fontName: String) {
    // TODO: Impleemnt
  }

  func update(image: NSImage, isTemplate: Bool = false) {
    self.image = image
    self.image?.isTemplate = isTemplate
  }

  func update(size: Int) {
    // TODO: Implement
  }

  private func getTag() -> String {
    return "Menu." + String(level)
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func getValue() -> String {
    return title
  }

  func toString() -> String {
    return getValue()
  }

  func apply() {
    guard hasDropdown() else {
      return print("Dropdown is disabled")
    }

    events = []
    for param in _params {
      param.applyTo(menu: self)
    }

    for menu in menus {
      menu.apply()
    }

    if menus.isEmpty {
      submenu = nil
    }

    if myParent?.submenu == nil {
      myParent?.submenu = NSMenu()
    }

    if isSeparator() {
      myParent?.submenu?.addItem(NSMenuItem.separator())
    } else {
      myParent?.submenu?.addItem(self)
    }
  }

  func shouldRefresh() -> Bool {
    return _params.reduce(false) {
      if let refresh = $1 as? Refresh {
        return $0 || refresh.getValue()
      }

      return $0
    }
  }

  func hasDropdown() -> Bool {
    for param in _params {
      if let dropdown = param as? Dropdown {
        return dropdown.getValue()
      }
    }

    return true
  }

  func isSeparator() -> Bool {
    return title.strip() == "-"
  }

  func openTerminal() -> Bool {
    return _params.reduce(false) {
      if let terminal = $1 as? Terminal {
        return $0 || terminal.getValue()
      }

      return $0
    }
  }

  func refresh() {
    refreshEvent.emit()
  }

  @objc func didClick(_ sender: NSMenu) {
    clickEvent.emit()
  }

  func onDidClick(block: @escaping () -> Void) {
    events.append(clickEvent.on(block))
  }

  func onDidRefresh(block: @escaping () -> Void) {
    events.append(refreshEvent.on(block))
  }

  func getArgs() -> [String] {
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

  func getTitle() -> String {
    return title
  }
}
