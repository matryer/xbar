import AppKit
import EmitterKit

final class Title: NSMenu, Menuable, TrayDelegate {
  var settings: [String : Bool] = [String: Bool]()
  var listener: Listener?
  var args = [String]()
  internal weak var titlable: TitleDelegate?
  internal var event = Event<Void>()
  internal var image: NSImage?
  internal var level: Int = 0
  internal var headline: Mutable
  internal var params = [Paramable]()

  /**
    @title A title to be displayed in the tray
    @params Parameters read and parsed from stdin, i.e terminal=false
    @menus Sub menus to be displayed when when the item is clicked
  */
  init(_ title: String, params: [Paramable], menus: [Menu] = []) {
    self.params = params
    self.headline = title.mutable()
    super.init(title: title)
    load()
    if shouldTrim() {
      set(headline: headline.trimmed())
    }
    add(menus: menus)
  }

  /**
    @errors A list of errors to be displayed in the sub menu
  */
  convenience init(errors: [String]) {
    self.init(":warning: ", params: [Paramable](), menus: errors.map { Menu($0) })
  }

  /**
    @error One error to be displayed in the sub menu
  */
  convenience init(error: String) {
    self.init(errors: [error])
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

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var isAltAlternate: Bool {
    return false
  }

  var isChecked: Bool {
    return false
  }

  var hasDropdown: Bool {
    return true
  }

  var isEnabled: Bool {
    return true
  }

  func isSeparator() -> Bool {
    return false
  }

  /**
    The below functions are optional
  */
  func shouldRefresh() -> Bool {
    return false
  }

  func openTerminal() -> Bool {
    return false
  }

  func add(menu: NSMenuItem) {
    addItem(menu)
  }

  func useAsAlternate() {
    /* NOP */
  }

  func set(state: Int) {
    /* NOP */
  }
}
