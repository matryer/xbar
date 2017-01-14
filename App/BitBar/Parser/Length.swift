import Cocoa

final class Length: IntValue {
  override func applyTo(menu: MenuDelegate) {
    guard menu.getTitle().characters.count > getValue() else {
      return print("Title is short enough")
    }

    guard getValue() > 0 else {
      return print("Length is to small")
    }

    menu.update(title: menu.getTitle()[0...getValue() - 1] + "…")
  }
}
