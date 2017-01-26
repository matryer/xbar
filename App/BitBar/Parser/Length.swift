import Foundation

final class Length: IntVal, Param {
  var priority = 0
  var length: Int { return int }

  func menu(didLoad menu: Menuable) {
    let attr = menu.getAttrs()
    guard attr.count > length else { return }
    guard length > 0 else { return }
    menu.update(attr: attr.truncate(length))
  }
}
