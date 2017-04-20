final class Terminal: Param<Bool> {
  var priority = 0

  override func menu(didLoad menu: Menuable) {
    menu.setting(terminal: value)
  }
}
