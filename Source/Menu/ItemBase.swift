import AppKit
import EmitterKit

/* TODO: Rename */
class ItemBase: NSMenuItem {
  private let event = Event<Void>()
  internal weak var parentable: Eventable?
  /**
    @title A title to be displayed
    @key A keyboard shortcut to simulate @self being clicked
  */
  init(_ title: String, checked: Bool = false, key: String = "", parentable: Eventable? = nil) {
    super.init(title: title, action: #selector(didClick), keyEquivalent: key)
    self.target = self
    self.attributedTitle = NSMutableAttributedString(withDefaultFont: title)
    self.parentable = parentable
    if checked {
      self.state = NSOnState
    }
    checkActive()
  }

  func add(menu: NSMenuItem) {
    if submenu == nil {
      submenu = NSMenu()
      submenu?.autoenablesItems = false
    }

    submenu?.addItem(menu)
    activate()
  }

  func addSub(_ title: String, checked: Bool = false, key: String = "", clickable: Bool, block: @escaping Block<Void>) -> Listener {
    let item = ItemBase(title, checked: checked, key: key)
    add(menu: item)

    if clickable {
      item.activate()
    }

    return item.onDidClick(block: block)
  }

  func addSub(_ title: String, key: String = "") {
    add(menu: ItemBase(title, key: key))
  }

  /**
    Append a separator to the submenu
   TODO: Rename
  */
  func separator() {
    add(menu: NSMenuItem.separator())
  }

  func set(title: String) {
    attributedTitle = Mutable(withDefaultFont: title)
  }

  func onDidClick(block: @escaping Block<Void>) -> Listener {
    return event.on(block)
  }

  @objc func didClick(_ sender: NSMenu) {
    event.emit()
  }

  func activate() {
    isEnabled = true
  }

  func deactivate() {
    isEnabled = false
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func checkActive() {
    isEnabled = !keyEquivalent.isEmpty || parentable != nil || hasSubmenu
  }
}
