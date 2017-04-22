final class Dropdown: Param<Bool> {
  var hasDropdown: Bool { return value }

  override func menu(didLoad menu: Menuable) {
    if !hasDropdown { menu.hideDropdown() }
  }
}
