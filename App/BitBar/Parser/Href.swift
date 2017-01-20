import Cocoa

final class Href: StringVal {
  override func applyTo(menu: MenuDelegate) {
    guard let url = URL(string: self.getValue()) else {
      return print("Could not parse URL \(getValue())")
    }

    menu.onDidClick {_ in
      NSWorkspace.shared().open(url)
    }
  }
}
