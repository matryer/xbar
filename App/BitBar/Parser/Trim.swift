final class Trim: BoolVal, Param {
  var priority = 11
  var active: Bool { return bool }

  func menu(didLoad menu: Menuable) {
    if active {
      /* FIXME: This replaces title. Use getAttrs instead */
      menu.update(title: menu.getTitle().trim())
    }
  }
}
