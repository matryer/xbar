final class Trim: Param<Bool> {
  var priority = 11

  override func menu(didLoad menu: Menuable) {
    menu.setting(trim: value)
  }
}
