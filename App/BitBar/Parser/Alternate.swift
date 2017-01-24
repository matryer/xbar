final class Alternate: BoolVal, Param {
  var priority: Int { return 0 }

  func applyTo(menu: Menuable) {
    guard getValue() else { return }
    menu.useAsAlternate()
  }
}
