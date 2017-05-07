import AppKit

extension NSMenuItem {
  weak var root: Parent? {
    get {
      if let menu = self as? BaseMenuItem {
        return menu._root
      } else {
        return nil
      }
    }

    set {
      if let menu = self as? BaseMenuItem {
        return menu._root = newValue
      } else {
        /* NOP */
      }
    }
  }

  var isSeparator: Bool {
    if let menu = self as? BaseMenuItem {
      if let attr = menu.attributedTitle {
        return attr.string.trimmed() == "-"
      }
      return menu.title.trimmed() == "-"
    } else {
      return isSeparatorItem
    }
  }
}
