final class Trim: BoolVal {
  override func applyTo(menu: Menuable) {
    guard getValue() else {
      return print("Trim is set to false")
    }

    menu.update(title: menu.getTitle().noMore())
  }
}
