import Cocoa

final class Checked: BoolVal {
  override func applyTo(menu: Menuable) {
    guard getValue() else {
      return print("Check box is turned off")
    }

    menu.update(state: NSOnState)
  }
}
