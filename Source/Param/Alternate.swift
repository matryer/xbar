final class Alternate: Param<Bool> {
  var priority = 0
  override func menu(didLoad menu: Menuable) {
    if value {
      menu.useAsAlternate()
    }
  }
}
