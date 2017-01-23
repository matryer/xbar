import Cocoa

final class Font: StringVal, Param  {
  func applyTo(menu: Menuable) {
    menu.update(fontName: getValue())
  }
}
