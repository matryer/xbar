import AppKit
import Parser
@testable import BitBar

extension BitBar.Menu: Menuable {
  var items: [NSMenuItem] { return submenu?.items ?? [] }
  var banner: Mutable {
    if let attr = attributedTitle {
      return attr.mutable()
    }

    return Mutable(string: "")
  }

  var act: Action {
    return paction
  }
}
