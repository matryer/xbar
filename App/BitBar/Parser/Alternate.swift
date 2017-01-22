import Cocoa

final class Alternate: BoolVal {
  override func applyTo(menu: Menuable) {
    guard getValue() else {
      return print("alternate is set to false")
    }

    menu.useAsAlternate()
  }
}
