final class Alternate: BoolVal, Param {
  var priority = 0
  func menu(didLoad menu: Menuable) {
    if bool {
      menu.useAsAlternate()
    }
  }
}
