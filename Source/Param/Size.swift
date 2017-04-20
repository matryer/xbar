final class Size: Param<Int> {
  var priority = 0

  override func menu(didLoad menu: Menuable) {
    // TODO: Size should parse a float, not int
    menu.set(size: Float(value))
  }
}
