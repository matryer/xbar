import Cocoa

final class Checked: BoolVal {
  override func applyTo(menu: Menuable) {
    guard getValue() else { return }
    menu.update(state: NSOnState)
  }
}
