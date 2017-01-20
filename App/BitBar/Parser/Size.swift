import Cocoa

final class Size: IntValue {
  override func applyTo(menu: MenuDelegate) {
    // TODO: Size should parse a float, not int
    menu.update(size: Float(getValue()))
  }
}
