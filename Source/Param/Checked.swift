import AppKit

final class Checked: Param<Bool> {
  override func menu(didLoad menu: Menuable) {
    menu.set(state: value ? NSOnState : NSOffState)
  }
}
