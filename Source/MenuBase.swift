import AppKit

class MenuBase: NSMenu, NSMenuDelegate {
  init() {
    super.init(title: "")
    self.delegate = self
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func menuWillOpen(_ menu: NSMenu) {
    for item in items {
      item.onWillBecomeVisible()
    }
  }
}

