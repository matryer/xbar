import Cocoa

final class Checked: BoolVal {
  override func applyTo(menu: MenuDelegate) {
    guard getValue() else {
      return print("Check box is turned off")
    }

    menu.update(state: NSOnState)
  }
}
