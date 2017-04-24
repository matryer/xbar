final class Dropdown: Param<Bool> {
  override var before: Filter { return Everyone }
  var hasDropdown: Bool { return value }

  override func menu(didLoad menu: Menuable) {
    if !hasDropdown { menu.hideDropdown() }
  }
}
