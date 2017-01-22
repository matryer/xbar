import AppKit
import EmitterKit

final class Title: NSMenu, Menuable {
  var menus = [Menu]() {
    willSet(menus) {
      apply(menus: menus)
    }
  }

  var image: NSImage? {
    get { return tray.image }
    set { tray.image = newValue }
  }

  var params: [Param] {
    get { return container.params }
    set { container.append(params: newValue) }
  }

  private var events = [Listener]()
  private let refreshEvent = Event<()>()
  private let tray: Tray
  private let container = Container()

  init(_ title: String, params: [Param], menus: [Menu]) {
    self.tray = Tray(title: title)
    super.init(title: title)
    container.delegate = self
    container.append(params: params)
    container.apply()
    self.menus = menus
    apply(menus: menus)
  }

  private func apply(menus: [Menu]) {
   guard container.hasDropdown() else {
    return
//     return removeAllSubMenus()
   }

    for menu in menus {
      if menu.isSeparator() {
        tray.add(item: NSMenuItem.separator())
      } else {
        tray.add(item: menu)
      }
    }
  }

  convenience init(errors: [String]) {
    let menus = errors.map { Menu($0, params: [], menus: []) }
    self.init(":warning:", params: [Emojize(true) as Param], menus: menus)
  }

  convenience init(error: String) {
    self.init(errors: [error])
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func onDidRefresh(block: @escaping () -> Void) {
    events.append(refreshEvent.on(block))
  }

  func shouldRefresh() -> Bool {
    return false
  }

  func onDidClick(block: @escaping () -> Void) {
    // TODO
  }

  var aTitle: NSMutableAttributedString {
    get { return tray.attributedTitle }
    set { tray.attributedTitle = newValue }
  }

  deinit { destroy() }
  func destroy() {
    tray.destroy()
  }

  func getTitle() -> String {
    return tray.attributedTitle.string
  }

  func getArgs() -> [String] {
    return []
  }

  func openTerminal() -> Bool {
    return false
  }

  func update(state: Int) {
    // Can't set state for title
  }

  // func applyTo(tray: Tray) {
  //   self.tray = tray
  //   tray.setMenu(self)
  //   update(title: title)
  //   for param in params {
  //     param.applyTo(menu: self)
  //   }
  // }

  func useAsAlternate() {
    // Not supported by title
  }

  func getValue() -> String {
    return title
  }

  func toString() -> String {
    return getValue()
  }

  func refresh() {
    // Not supported by menu item
  }
}
