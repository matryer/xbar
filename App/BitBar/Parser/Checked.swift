import Cocoa

final class Checked: BoolVal, Param {
  var priority: Int { return 0 }
  
  func applyTo(menu: Menuable) {
    guard getValue() else { return }
    menu.update(state: NSOnState)
  }
}
