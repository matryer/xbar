import AppKit
@testable import BitBar

extension Title: Menuable {
  func onWillBecomeVisible() {}
  var isClickable: Bool {
    return isEnabled
  }

  var isEnabled: Bool {
    return true
  }

  var banner: Mutable {
    return Mutable(string: "") /* TODO: Remove */
  }

  var image: NSImage? { return nil }
  var isSeparator: Bool { return false }
  var isChecked: Bool { return false  }
  var isAlternate: Bool { return false }
  var keyEquivalent: String { return "" }
  func onDidClick() {}
}

extension PluginFile: Menuable {
  func onWillBecomeVisible() {}
  var isClickable: Bool {
    return title?.isClickable ?? false
  }

  var items: [NSMenuItem] {
    return title?.items ?? []
  }

  var isEnabled: Bool {
    return true
  }

  var banner: Mutable {
    if let title = tray.attributedTitle {
      return title.mutable
    } else {
      return Mutable(string: "")
    }
  }

  var image: NSImage? { return nil }
  var isSeparator: Bool { return false }
  var isChecked: Bool { return false  }
  var isAlternate: Bool { return false }
  var keyEquivalent: String { return "" }
  func onDidClick() {}
}
