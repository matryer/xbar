final class Alternate: Param<Bool> {
  override func menu(didLoad menu: Menuable) {
    if value { menu.useAsAlternate() }
  }
}
