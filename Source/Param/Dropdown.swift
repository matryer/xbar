final class Dropdown: Param<Bool> {
  var priority = 0

  override func menu(didLoad menu: Menuable) {
    menu.setting(dropdown: value)
  }
}
