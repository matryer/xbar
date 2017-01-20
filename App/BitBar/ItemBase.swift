import AppKit
import EmitterKit

class ItemBase: NSMenuItem {
  var listeners = [Listener]()
  let clickEvent = Event<ItemBase>()

  init(_ title: String, key: String = "", block: @escaping (ItemBase) -> Void) {
    super.init(title: title, action: #selector(didClick), keyEquivalent: key)
    target = self
    isEnabled = true
    listeners.append(clickEvent.on(block))
    attributedTitle = NSMutableAttributedString(withDefaultFont: title)
  }

  convenience init(_ title: String, key: String = "", blockWithoutParam: @escaping () -> Void) {
    self.init(title, key: key) { (_: ItemBase) in blockWithoutParam() }
  }

  convenience init(_ title: String, key: String = "") {
    self.init(title, key: key) { /* TODO: Remove this */ }
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func didClick(_ sender: NSMenu) {
    clickEvent.emit(self)
  }

  internal func onDidClick(block: @escaping () -> Void) {
    listeners.append(clickEvent.on { _ in block() })
  }
}
