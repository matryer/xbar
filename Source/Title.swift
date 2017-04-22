import AppKit
import EmitterKit

final class Title: NSMenu, Menuable, TrayDelegate {
  var listener: Listener?
  var args = [String]()
  internal weak var titlable: TitleDelegate?
  internal var event = Event<Void>()
  internal var image: NSImage?
  internal var level: Int = 0
  internal var headline: Mutable
  internal var params = [Paramable]()

  init(_ title: String, params: [Paramable] = [Paramable](), menus: [Menu] = []) {
    self.params = params
    self.headline = title.mutable()
    super.init(title: title)
    add(menus: menus)
  }

  /**
    @errors A list of errors to be displayed in the sub menu
  */
  convenience init(errors: [String]) {
    self.init(":warning: ".emojifyed(), menus: errors.map(Menu.init))
  }

  convenience init(error: String) {
    self.init(errors: [error])
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func tray(didClickOpenInTerminal: Tray) {
    self.titlable?.title(didClickOpenInTerminal: self)
  }

  func tray(didTriggerRefresh: Tray) {
    self.titlable?.title(didTriggerRefresh: self)
  }

  func onDidClick(block: @escaping Block<Void>) -> Listener {
    return event.on(block)
  }

  func submenu(didTriggerRefresh menu: Menuable) {
    self.refresh()
  }

  func refresh() {
    titlable?.title(didTriggerRefresh: self)
  }

  func isSeparator() -> Bool {
    return false
  }

  func add(menu: NSMenuItem) {
    addItem(menu)
  }

  func useAsAlternate() {
    preconditionFailure("Title can't be use as an alternativ menu")
  }

  func set(state: Int) {
    preconditionFailure("State can't be set on title")
  }

  func hideDropdown() {
    preconditionFailure("[TODO] Not yet implemeted")
  }

  func hide() {
    preconditionFailure("[TODO] Not yet implemented")
  }

  var openInTerminal: Bool {
    preconditionFailure("Title has no notion terminal")
  }

  var isAltAlternate: Bool {
    return false
  }

  var isChecked: Bool {
    return false
  }

  var isEnabled: Bool {
    return true
  }
}
