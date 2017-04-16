import AppKit
import EmitterKit
// import Emojize

protocol TitleDelegate: class {
  func name(didClickOpenInTerminal: Title)
  func name(didTriggerRefresh: Title)
}

protocol TrayDelegate: class {
  func bar(didClickOpenInTerminal: Tray)
  func bar(didTriggerRefresh: Tray)
}

final class Title: NSMenu, Menuable, TrayDelegate {
  var aTitle: Mutable

  internal var container: Container
  internal var menus = [Menu]()
  internal weak var titlable: TitleDelegate?
  internal var event = Event<Void>()
  internal var image: NSImage?
  internal var level: Int = 0
  internal var toBeRemoved = [NSMenuItem]()
  internal var toBeAdded = [NSMenuItem]()

  func onDidClick(block: @escaping Block<Void>) -> Listener {
    return event.on(block)
  }

  /**
    @title A title to be displayed in the tray
    @params Parameters read and parsed from stdin, i.e terminal=false
    @menus Sub menus to be displayed when when the item is clicked
  */
  init(_ title: String, container: Container = Container(), menus: [Menu] = []) {
    self.aTitle = title.mutable() // Mutable(withDefaultFont: title)
    self.container = container
    super.init(title: title)
    add(menus: menus)
    container.delegate = self
  }

  /**
    @errors A list of errors to be displayed in the sub menu
  */
  convenience init(errors: [String]) {
    self.init(":warning: ", container: Container(), menus: errors.map { Menu($0) })
  }

  func bar(didClickOpenInTerminal: Tray) {
    self.titlable?.name(didClickOpenInTerminal: self)
  }

  func bar(didTriggerRefresh: Tray) {
    self.titlable?.name(didTriggerRefresh: self)
  }

  func remove(menu: NSMenuItem) {
    toBeRemoved.append(menu)
  }

  /**
    @error One error to be displayed in the sub menu
  */
  convenience init(error: String) {
    self.init(errors: [error])
  }

  /**
    Adds a warning icon before error message passed
  */
  func add(error: String) {
    print("[Title] error", error)
    /* TODO: Implement */
  }

  /**
    Add menu to the list of sub menus
  */
  func add(menu: NSMenuItem) {
    toBeAdded.append(menu)
  }

  func submenu(didTriggerRefresh menu: Menuable) {
    self.refresh()
  }

  func refresh() {
    self.titlable?.name(didTriggerRefresh: self)
  }

  /**
    Update @tray with the latest data
  */
  func apply(to tray: Tray) {
    tray.attributedTitle = aTitle
    tray.image = image
    tray.delegate = self

    for menu in toBeAdded {
      tray.add(item: menu)
    }

    for menu in toBeRemoved {
      tray.remove(menu: menu)
    }

    toBeRemoved = []
    toBeAdded = []

    tray.refresh()
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
}
