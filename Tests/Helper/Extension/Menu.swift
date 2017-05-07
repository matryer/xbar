import AppKit
import Parser
@testable import BitBar

extension BitBar.Menu: Menuable {
  var items: [NSMenuItem] { return submenu?.items ?? [] }
  var banner: Mutable {
    return headline
  }

  var isChecked: Bool { return state == NSOnState  }
  var act: Action {
    if let act = paction {
      return act
    }

    return .nop
  }
}
