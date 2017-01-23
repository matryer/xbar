final class Alternate: BoolVal, Param {
  func applyTo(menu: Menuable) {
    guard getValue() else { return }
    menu.useAsAlternate()
  }
}
