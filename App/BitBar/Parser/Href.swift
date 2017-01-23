import Cocoa

final class Href: StringVal, Param {
  var priority: Int { return 0 }

  func applyTo(menu: Menuable) {
    guard let url = URL(string: self.getValue()) else {
      return menu.add(error: "Could not parse URL with value \(getValue())")
    }

    menu.onDidClick {_ in
      NSWorkspace.shared().open(url)
    }
  }
}
