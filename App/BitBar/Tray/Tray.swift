import AppKit
import EmitterKit
import DateTools

class Tray: Base, NSMenuDelegate {
  let item: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  weak var delegate: TrayDelegate?
  var updatedAt = NSDate()

  init(title: String, isVisible: Bool? = false) {
    item.title = title
    super.init()
    if isVisible! { show() }
  }

  internal func show() {
    log("show", "Tray is being shown")
    if #available(OSX 10.12, *) {
      item.isVisible = true
    } else {
      // TODO: Fallback on earlier versions
    }
  }

  internal func hide() {
    log("hide", "Tray is hiding")
    if #available(OSX 10.12, *) {
      item.isVisible = false
    } else {
      // TODO: Fallback on earlier versions
    }
  }

  internal func clear(title: String) {
    item.menu?.removeAllItems()
    item.title = title
  }

  @objc internal func onDidClickMenu() {
    log("onDidClickMenu", "Clicked menu button")
  }

  internal func menuWillOpen(_ menu: NSMenu) {
    // TODO
  }

  // TODO: Use
  private func getUpdatedWhen() -> String {
    return "Updated " + updatedAt.timeAgoSinceNow()
  }
}
