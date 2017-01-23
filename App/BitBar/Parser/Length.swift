import Cocoa

final class Length: IntValue, Param {
  func applyTo(menu: Menuable) {
    let attr = menu.getAttrs()
    guard attr.count > getValue() else { return }
    guard getValue() > 0 else { return }
    menu.update(attr: attr.truncate(getValue()))
  }
}
