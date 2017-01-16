import AppKit
import EmitterKit
import DateTools

// TODO: Move this to its own file
final class Item: NSMenuItem {
  var listeners = [Listener]()
  let clickEvent = Event<()>()

  init(_ title: String, key: String = "", block: @escaping () -> ()) {
    super.init(title: title, action: #selector(didClick), keyEquivalent: key)
    target = self
    isEnabled = true
    listeners.append(clickEvent.on(block))
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func didClick(_ sender: NSMenu) {
    clickEvent.emit()
  }
}

class Tray: Base, NSMenuDelegate {
  let item: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  weak var delegate: TrayDelegate?
  var updatedAt = NSDate()

  init(title: String, isVisible: Bool? = false) {
    item.title = title
    super.init()
    if isVisible! { show() }
    setPrefs()
  }

  internal func show() {
    log("show", "Tray is being shown")
    if #available(OSX 10.12, *) {
      item.isVisible = true
    } else {
      // TODO: Fallback on earlier versions
    }
  }

  func setMenu(_ menu: NSMenu) {
    item.menu = menu
    setPrefs()
  }

  private func separator() {
    item.menu?.addItem(NSMenuItem.separator())
  }

  private func setPrefs() {
    separator()
    item.menu?.addItem(Item("Refresh All", key: "r") {
      print("Refresh All")
    })

    separator()

    item.menu?.addItem(Item("Change Plugin Folder…") {
      print("Change Plugin Folder…")
    })

    item.menu?.addItem(Item("Open Plugin Folder…") {
      print("Open Plugin Folder…")
    })

    item.menu?.addItem(Item("Get Plugins…") {
      print("Get Plugins…")
    })

    separator()

    item.menu?.addItem(Item("Open at Login") {
      print("Open at Login")
    })

    separator()

    item.menu?.addItem(Item("Check for Updates…") {
      print("Check for Updates…")
    })

    item.menu?.addItem(Item("Quit", key: "q") {
      print("Quit")
    })
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
