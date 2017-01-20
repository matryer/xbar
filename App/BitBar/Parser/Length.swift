import Cocoa

final class Length: IntValue {
  override func applyTo(menu: MenuDelegate) {
    let attr = menu.getAttrs()
    guard attr.count > getValue() else {
      return print("Title is short enough")
    }

    guard getValue() > 0 else {
      return print("Length is to small")
    }

    menu.update(attr: attr.truncate(getValue()))
  }
}
