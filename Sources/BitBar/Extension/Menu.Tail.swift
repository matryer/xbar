import AppKit
import Parser

extension Parser.Menu.Tail {
  var menuItem: NSMenuItem {
    if isSeparator { return NSMenuItem.separator() }
    return Menu(tail: self)
  }

  var isSeparator: Bool {
    switch self {
    case .separator:
      return true
    default:
      return false
    }
  }
}
