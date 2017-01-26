import AppKit

final class Checked: IntVal, Param {
  var priority = 0

  convenience init(_ isChecked: Bool) {
    self.init(isChecked ? NSOnState : NSOffState)
  }

  func menu(didLoad menu: Menuable) {
    menu.update(state: int)
  }
}
