final class Font: StringVal, Param {
  var priority = 0
  var name: String { return value }

  func menu(didLoad menu: Menuable) {
    menu.update(fontName: name)
  }
}
