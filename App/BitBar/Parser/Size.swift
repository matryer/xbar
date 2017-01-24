import Cocoa

final class Size: IntValue, Param {
  var priority: Int { return 0 }

  func applyTo(menu: Menuable) {
    // TODO: Size should parse a float, not int
    menu.update(size: Float(getValue()))
  }
}
