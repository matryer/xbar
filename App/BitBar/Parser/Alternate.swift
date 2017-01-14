import Cocoa

final class Alternate: BoolVal {
  override func applyTo(menu: MenuDelegate) {
    guard getValue() else {
      return print("alternate is set to false")
    }

    menu.useAsAlternate()
  }
}
