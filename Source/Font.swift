final class Font: StringVal, Param {
  var priority = 0
  var name: String { return data }

  func menu(didLoad menu: Menuable) {
    menu.set(fontName: name)
  }
}
