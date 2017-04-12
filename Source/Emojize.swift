import Emojize

final class Emojize: BoolVal, Param {
  var priority = 15
  var active: Bool { return bool }

  func menu(didLoad menu: Menuable) {
    guard active else { return }
    menu.set(title: menu.getTitle().emojifyed())
  }
}
