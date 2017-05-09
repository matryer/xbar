import AppKit

/*
  FIXME: The code below is a result of NSMenuItem.separator()
  not being inheritable. Should be solvable in a better way
*/
extension NSMenuItem {
  weak var root: Parent? {
    get {
      if let menu = self as? MenuItem {
        return menu._root
      } else {
        return nil
      }
    }

    set {
      if let menu = self as? MenuItem {
        return menu._root = newValue
      } else {
        /* NOP */
      }
    }
  }

  var isSeparator: Bool {
    if let menu = self as? MenuItem {
      if let attr = menu.attributedTitle {
        return attr.string.trimmed() == "-"
      }
      return menu.title.trimmed() == "-"
    } else {
      return isSeparatorItem
    }
  }
}
