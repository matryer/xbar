import AppKit
import EmitterKit

protocol TitleDelegate: class {
  func name(didClickOpenInTerminal: Title)
  func name(didTriggerRefresh: Title)
}

protocol TrayDelegate: class {
  func bar(didClickOpenInTerminal: Tray)
  func bar(didTriggerRefresh: Tray)
}

final class Title: NSMenu, Menuable, TrayDelegate {
  internal let container = Container()
  internal var menus = [Menu]()
  internal weak var titlable: TitleDelegate?
  internal var event = Event<Void>()

  var level: Int = 0
  private var tray: Tray!

  var image: NSImage? {
    get { return tray.image }
    set { tray.image = newValue }
  }

  var aTitle: NSMutableAttributedString {
    get { return tray.attributedTitle }
    set { tray.attributedTitle = newValue }
  }

  func onDidClick(block: @escaping Block<Void>) -> Listener {
    return event.on(block)
  }

  /**
    @title A title to be displayed in the tray
    @params Parameters read and parsed from stdin, i.e terminal=false
    @menus Sub menus to be displayed when when the item is clicked
  */
  init(_ title: String, params: [Param], menus: [Menu]) {
    super.init(title: title)
    tray = Tray(title: title, isVisible: true, delegate: self)
    add(menus: menus)
    add(params: params)
  }

  /**
    @errors A list of errors to be displayed in the sub menu
  */
  convenience init(errors: [String]) {
    let menus = errors.map { Menu($0, params: [], menus: []) }
    self.init(":warning:", params: [Emojize(true) as Param], menus: menus)
  }

  func bar(didClickOpenInTerminal: Tray) {
    self.titlable?.name(didClickOpenInTerminal: self)
  }

  func bar(didTriggerRefresh: Tray) {
    self.titlable?.name(didTriggerRefresh: self)
  }

  /**
    @error One error to be displayed in the sub menu
  */
  convenience init(error: String) {
    self.init(errors: [error])
  }

  /**
    Append @menu to the list of sub menus for @self
  */
  func add(menu: NSMenuItem) {
    tray.add(item: menu)
  }

  // TODO: Implement
  func add(error: String) {
    // print("Got error in title", error)
  }

  func submenu(didTriggerRefresh menu: Menuable) {
    self.refresh()
  }

  func refresh() {
    self.titlable?.name(didTriggerRefresh: self)
  }

  /**
    Removes tray from menu bar
  */
  func destroy() {
    tray.destroy()
  }
  deinit { destroy() }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
