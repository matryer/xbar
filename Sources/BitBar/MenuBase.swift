import AppKit
import Async
import SwiftyBeaver

class MenuBase: NSMenu, NSMenuDelegate, GUI, Parent {
  internal let log = SwiftyBeaver.self
  internal weak var root: Parent?
  internal let queue = MenuBase.newQueue(label: "MenuBase")
  init() {
    super.init(title: "")
    self.delegate = self
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func menuWillOpen(_ menu: NSMenu) {
    perform {
      for item in self.items {
        item.onWillBecomeVisible()
      }
    }
  }

  public func add(submenu: NSMenuItem, at index: Int) {
    perform {
      submenu.root = self
      self.insertItem(submenu, at: index)
    }
  }

  public func remove(at index: Int) {
    perform { self.removeItem(at: index) }
  }
}
