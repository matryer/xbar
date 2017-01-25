import Cocoa
import EmitterKit

final class Href: StringVal, Param {
  var priority: Int { return 0 }
  var listener: Listener?
  
  func applyTo(menu: Menuable) {
    guard let url = URL(string: self.getValue()) else {
      return menu.add(error: "Could not parse URL with value \(getValue())")
    }

    listener = menu.onDidClick {
      NSWorkspace.shared().open(url)
    }
  }
}
