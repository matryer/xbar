import Cocoa

final class Size: IntValue, Param {
  func applyTo(menu: Menuable) {
    // TODO: Size should parse a float, not int
    menu.update(size: Float(getValue()))
  }
}
