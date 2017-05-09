import AppKit
import Parser
@testable import BitBar

extension MenuItem: Menuable {
  var items: [NSMenuItem] { return submenu?.items ?? [] }
  var banner: Mutable {
    if let attr = attributedTitle {
      return attr.mutable()
    }

    return Mutable(string: "")
  }

  var act: Action {
    if let menu = self as? BitBar.Menu {
      return menu.paction
    }
    return .nop
  }
}
