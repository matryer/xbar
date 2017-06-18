import AppKit
import Parser
@testable import BitBar

extension MenuItem: Menuable {
  var items: [NSMenuItem] { return submenu?.items ?? [] }
  var banner: Mutable {
    if let attr = attributedTitle {
      return Mutable(attributedString: attr)
    }

    return "".mutable()
  }

  var act: Action {
    if let menu = self as? BitBar.Menu {
      return menu.paction
    }
    return .nop
  }
}
