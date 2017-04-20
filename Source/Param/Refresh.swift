final class Refresh: Param<Bool> {
  var priority = 0

  override func menu(didLoad menu: Menuable) {
    menu.setting(refresh: value)
  }
}
