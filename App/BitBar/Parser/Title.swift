import AppKit
import EmitterKit

final class Title: NSMenu, MenuDelegate {
  var events = [Listener]()
  var menus = [Menu]()
  var params = [Param]()
  let refreshEvent = Event<()>()
  var tray: Tray?
  var defaultFont: NSFont? = NSFont.menuFont(ofSize: NSFont.systemFontSize())
  var attr: NSMutableAttributedString?

  init(_ title: String, params: [Param], menus: [Menu]) {
    super.init(title: title)
    if let font = defaultFont {
      attr = NSMutableAttributedString(
        string: title,
        attributes: [NSFontAttributeName: font]
      )
    }

    self.params = params
    self.menus = menus
    for menu in menus {
      addItem(menu)
      menu.apply()
      menu.onDidRefresh {
        self.refreshEvent.emit()
      }
    }
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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

  func update(attr: NSMutableAttributedString) {
    self.attr = attr
    tray?.item.attributedTitle = attr
  }

  func onDidClick(block: @escaping () -> ()) {
    // TODO
  }

  func update(image: NSImage, isTemplate: Bool = false) {
    tray?.item.image = image
  }

  func update(key: String, value: Any) {
    guard let attributes = attr else {
      return print("No attribute found")
    }
    attributes.addAttribute(key, value: value, range: NSMakeRange(0, attributes.length))
    update(attr: attributes)
  }

  func update(fontName: String) {
    guard let size = defaultFont?.pointSize else {
      return print("No default font size found")
    }

    guard let name = defaultFont?.fontName else {
      return print("No font name found")
    }

    guard let font = NSFont(name: name, size: size) else {
      return print("Could not apply font ", fontName)
    }

    self.defaultFont = font
    update(key: NSFontAttributeName, value: font)
  }

  func update(size: Int) {
    guard let name = defaultFont?.fontName else {
      return print("No font name found")
    }

    guard let font = NSFont(name: name, size: CGFloat(size)) else {
      return print("Can't use size: \(size) with font \(defaultFont?.fontName)")
    }

    self.defaultFont = font
    update(key: NSFontAttributeName, value: font)
  }

  func update(color: NSColor) {
    update(key: NSForegroundColorAttributeName, value: color)
  }

  func getTitle() -> String {
    return attr?.string ?? ""
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
    tray.item.menu = self
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
}
