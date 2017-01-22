final class Trim: BoolVal {
  override func applyTo(menu: Menuable) {
    guard getValue() else { return }
    menu.update(title: menu.getTitle().noMore())
  }
}
