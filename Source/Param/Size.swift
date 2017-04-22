final class Size: Param<Int> {
  override func menu(didLoad menu: Menuable) {
    // TODO: Size should parse a float, not int
    menu.set(size: Float(value))
  }
}
