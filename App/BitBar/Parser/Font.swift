import Cocoa

final class Font: StringVal {
  override func applyTo(menu: Menuable) {
    menu.update(fontName: getValue())
  }
}
