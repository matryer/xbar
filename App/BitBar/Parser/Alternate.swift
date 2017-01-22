final class Alternate: BoolVal {
  override func applyTo(menu: Menuable) {
    guard getValue() else { return }
    menu.useAsAlternate()
  }
}
