import AppKit
@testable import BitBar

extension Menu: Menuable {
  var items: [NSMenuItem] { return submenu?.items ?? [] }
  var banner: Mutable {
    return headline
  }

  var isChecked: Bool { return state == NSOnState  }
}
