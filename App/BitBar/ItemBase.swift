import AppKit
import EmitterKit

/* TODO: Rename */
class ItemBase: NSMenuItem {
  private let event = Event<ItemBase>()
  private weak var delegate: ItemBaseDelegate? {
    didSet { checkActive() }
  }
  // TODO: Remove listeners to reduce the risk the memory leaks
  private var listeners = [Listener]() {
    didSet { checkActive() }
  }

  private func checkActive() {
    isEnabled = !keyEquivalent.isEmpty || !listeners.isEmpty || delegate != nil
  }

  /**
    @title A title to be displayed
    @key A keyboard shortcut to simulate @self being clicked
  */
  init(_ title: String, checked: Bool = false, key: String = "", delegate: ItemBaseDelegate? = nil) {
    super.init(title: title, action: #selector(didClick), keyEquivalent: key)
    self.target = self
    self.attributedTitle = NSMutableAttributedString(withDefaultFont: title)
    self.delegate = delegate
    if checked {
      self.state = NSOnState
    }

    checkActive()
  }

  /**
    Add @menu as a submenu to @self
  */
  func addSub(_ menu: NSMenuItem) {
    if submenu == nil {
      submenu = NSMenu()
      submenu?.autoenablesItems = false
    }

    submenu?.addItem(menu)
    activate()
  }

  func addSub(_ title: String, checked: Bool, key: String = "", clickable: Bool, block: @escaping Block<ItemBase>) {
    let item = ItemBase(title, checked: checked, key: key)
    listeners.append(item.onDidClick(block: block))
    addSub(item)

    if clickable {
      item.activate()
    }
  }

  func addSub(_ title: String, key: String = "", clickable: Bool, blockWO: @escaping Block<Void>) {
    addSub(title, checked: false, key: key, clickable: clickable, block: { (_:ItemBase) in blockWO() })
  }

  func addSub(_ title: String, key: String = "") {
    addSub(ItemBase(title, key: key))
  }

  /**
    Append a separator to the submenu
  */
  func separator() {
    addSub(NSMenuItem.separator())
  }

  func set(title: String) {
    attributedTitle = NSMutableAttributedString(withDefaultFont: title)
  }

  func removeAllSubMenus() {
    submenu?.removeAllItems()
  }

  func onDidClick(block: @escaping Block<ItemBase>) -> Listener {
    return event.on(block)
  }

  func onDidClick(block: @escaping Block<Void>) -> Listener {
    return onDidClick { (_:ItemBase) in block() }
  }

  @objc private func didClick(_ sender: NSMenu) {
    trigger()
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

  // For testing
  internal func trigger() {
    delegate?.item(didClick: self)
    event.emit(self)
  }
}
