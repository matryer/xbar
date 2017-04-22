final class Font: Param<String> {
  override var original: String {
    return escape(value)
  }

  override func menu(didLoad menu: Menuable) {
    menu.set(fontName: value)
  }
}
