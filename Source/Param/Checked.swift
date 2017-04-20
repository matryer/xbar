import AppKit

final class Checked: Param<Bool> {
  var priority = 0

  override func menu(didLoad menu: Menuable) {
    menu.set(state: value ? NSOnState : NSOffState)
  }
}
