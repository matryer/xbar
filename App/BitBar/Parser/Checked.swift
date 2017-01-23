import Cocoa

final class Checked: BoolVal, Param {
  func applyTo(menu: Menuable) {
    guard getValue() else { return }
    menu.update(state: NSOnState)
  }
}
