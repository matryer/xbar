import AppKit
import EmitterKit

final class Title: NSMenu, Menuable {
  internal var events = [Listener]()
  internal var refreshEvent = Event<()>()
  internal let container = Container()
  internal var menus = [Menu]()
  private let tray: Tray

  var image: NSImage? {
    get { return tray.image }
    set { tray.image = newValue }
  }

  var aTitle: NSMutableAttributedString {
    get { return tray.attributedTitle }
    set { tray.attributedTitle = newValue }
  }

  /**
    @title A title to be displayed in the tray
    @params Parameters read and parsed from stdin, i.e terminal=false
    @menus Sub menus to be displayed when when the item is clicked
  */
  init(_ title: String, params: [Param], menus: [Menu]) {
    tray = Tray(title: title)
    super.init(title: title)
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
