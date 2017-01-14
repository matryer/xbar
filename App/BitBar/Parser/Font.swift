import Cocoa

final class Font: StringVal {
  override func applyTo(menu: MenuDelegate) {
    menu.update(fontName: getValue())
  }
}
