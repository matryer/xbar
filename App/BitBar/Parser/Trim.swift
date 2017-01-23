final class Trim: BoolVal, Param {
  var priority: Int { return 11 }

  func applyTo(menu: Menuable) {
    if getValue() {
      /* FIXME: This replaces title. Use getAttrs instead */
      menu.update(title: menu.getTitle().noMore())
    }
  }
}
