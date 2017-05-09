import AppKit
@testable import BitBar

extension Title: Menuable {
  func onDidClick() {
    /* TODO */
  }

  var isEnabled: Bool {
    return true
  }

  var banner: Mutable {
    return headline ?? Mutable(string: "")
  }

  var image: NSImage? { return nil }
  var isSeparator: Bool { return false }
  var isChecked: Bool { return false  }
  var isAlternate: Bool { return false }
  var keyEquivalent: String { return "" }
}
