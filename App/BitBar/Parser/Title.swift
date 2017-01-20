import AppKit
import EmitterKit

final class Title: NSMenu, MenuDelegate {
  var events = [Listener]()
  var menus = [Menu]()
  var params = [Param]()
  let refreshEvent = Event<()>()
  var tray: Tray?

  init(_ title: String, params: [Param], menus: [Menu]) {
    super.init(title: title)
    self.params = params
    self.menus = menus
    for menu in menus {
      if menu.isSeparator() {
        addItem(NSMenuItem.separator())
      } else {
        addItem(menu)
        menu.apply()
        menu.onDidRefresh {
          self.refreshEvent.emit()
        }
      }
    }
  }

  convenience init(errors: [String]) {
    let menus = errors.map { Menu($0, params: [], menus: []) }
    self.init(":warning:", params: [Emojize(true) as Param], menus: menus)
  }

  convenience init(error: String) {
    self.init(errors: [error])
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  internal func getAttrs() -> NSMutableAttributedString {
    return currentTitle()
  }

  func onDidRefresh(block: @escaping () -> Void) {
    events.append(refreshEvent.on(block))
  }

  func shouldRefresh() -> Bool {
    return false
  }

  func update(title: String) {
    update(attr: NSMutableAttributedString(string: title))
  }

  // TODO: Rename to set
  func update(attr: NSMutableAttributedString) {
    set(title: currentTitle().merge(attr))
  }

  func update(attrs: [String: Any]) {
    set(title: currentTitle().update(attr: attrs))
  }

  func onDidClick(block: @escaping () -> Void) {
    // TODO
  }

  func update(image: NSImage, isTemplate: Bool = false) {
    tray?.item.image = image
  }

  func update(key: String, value: Any) {
    update(attrs: [key: value])
  }

  func update(fontName: String) {
    set(title: currentTitle().update(fontName: fontName))
  }

  func set(title: NSMutableAttributedString) {
    tray?.item.attributedTitle = title
  }

  func update(size: Float) {
    set(title: currentTitle().update(fontSize: size))
  }

  func update(color: NSColor) {
    update(key: NSForegroundColorAttributeName, value: color)
  }

  func getTitle() -> String {
    return tray?.item.attributedTitle?.string ?? ""
  }

  func getArgs() -> [String] {
    return []
  }

  func openTerminal() -> Bool {
    return false
  }

  func update(state: Int) {
    // Can't set state for title
  }

  func applyTo(tray: Tray) {
    self.tray = tray
    tray.setMenu(self)
    update(title: title)
    for param in params {
      param.applyTo(menu: self)
    }
  }

  func useAsAlternate() {
    // Not supported by title
  }

  func getValue() -> String {
    return title
  }

  func toString() -> String {
    return getValue()
  }

  func refresh() {
    // Not supported by menu item
  }

  private func currentTitle() -> NSMutableAttributedString {
    if let title = tray?.item.attributedTitle {
      return title.mutable()
    }

    return NSMutableAttributedString(string: self.title)
  }
}
