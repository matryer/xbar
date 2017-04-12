final class Trim: BoolVal, Param {
  var priority = 11
  var active: Bool { return bool }

  func menu(didLoad menu: Menuable) {
    if active {
      menu.set(title: menu.getAttrs().trimmed())
    }
  }
}