import Cocoa

final class Length: IntValue, Param {
  var priority: Int { return 0 }

  func applyTo(menu: Menuable) {
    let attr = menu.getAttrs()
    guard attr.count > getValue() else { return }
    guard getValue() > 0 else { return }
    menu.update(attr: attr.truncate(getValue()))
  }
}
