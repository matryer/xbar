final class Size: FloatVal, Param {
  var priority = 0

  func menu(didLoad menu: Menuable) {
    // TODO: Size should parse a float, not int
    menu.update(size: float)
  }
}
