import AppKit
import EmitterKit

class ItemBase: NSMenuItem {
  let clickEvent = Event<ItemBase>()
  var listeners = [Listener]() {
    didSet { activate() }
  }

  init(_ title: String, key: String = "", block: @escaping Block<ItemBase>) {
    super.init(title: title, action: #selector(didClick), keyEquivalent: key)
    target = self
    listeners.append(clickEvent.on(block))
    activate()
    attributedTitle = NSMutableAttributedString(withDefaultFont: title)
  }

  convenience init(_ title: String, key: String = "", voidBlock: @escaping Block<Void>) {
    self.init(title, key: key) { (_: ItemBase) in voidBlock() }
  }

  init(_ title: String, key: String = "") {
    super.init(title: title, action: nil, keyEquivalent: key)
    if key.isEmpty { deactivate() }
    else { activate() }
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func addSub(_ menu: NSMenuItem) {
    if submenu == nil { submenu = NSMenu() }
    submenu?.addItem(menu)
    activate()
  }

  func addSub(_ name: String, checked: Bool = false, key: String = "", block: @escaping Block<Void>) {
    addSub(name, checked: checked, key: key) { (_:ItemBase) in block() }
  }

  func addSub(_ name: String, checked: Bool = false, key: String = "", voidBlock: @escaping Block<ItemBase>) {
    let menu = ItemBase(name, key: key) { item in voidBlock(item) }
    addSub(menu)
    menu.state = checked ? NSOnState : NSOffState
  }

  @objc func didClick(_ sender: NSMenu) {
    clickEvent.emit(self)
  }

  func onDidClick(block: @escaping () -> Void) {
    listeners.append(clickEvent.on { _ in block() })
  }

  func separator() {
    addSub(NSMenuItem.separator())
  }

  private func activate() {
    isEnabled = true
  }

  private func deactivate() {
    isEnabled = false
  }
}
