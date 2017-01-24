import Cocoa

final class Font: StringVal, Param {
  var priority: Int { return 0 }

  func applyTo(menu: Menuable) {
    menu.update(fontName: getValue())
  }
}
