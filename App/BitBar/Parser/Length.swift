import Cocoa

final class Length: IntValue {
  override func applyTo(menu: MenuDelegate) {
    let attr = menu.getAttrs()
    guard attr.count > getValue() else {
      return
    }

    guard getValue() > 0 else {
      return
    }

    menu.update(attr: attr.truncate(getValue()))
  }
}
