final class Trim: BoolVal {
  override func applyTo(menu: MenuDelegate) {
    guard getValue() else {
      return print("Trim is set to false")
    }

    menu.update(title: menu.getTitle().noMore())
  }
}
