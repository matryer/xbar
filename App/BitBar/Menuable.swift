import Cocoa
import EmitterKit

protocol Menuable: class {
  var level: Int { get set }
  var aTitle: NSMutableAttributedString { get set }
  var image: NSImage? { get set }
  var container: Container { get set }
  var title: String { get set }
  var menus: [Menu] { get set }
  var event: Event<Void> { get set }
  func getTitle() -> String
  func getAttrs() -> NSMutableAttributedString
  func onDidClick(block: @escaping Block<Void>) -> Listener
  func useAsAlternate()
  func activate()
  func refresh()
  func getArgs() -> [String]
  func openTerminal() -> Bool
  func shouldRefresh() -> Bool
  func update(attr: NSMutableAttributedString)
  func update(state: Int)
  func update(color: NSColor)
  func update(fontName: String)
  func update(size: Float)
  func update(image: NSImage, isTemplate: Bool)
  func update(title: String)
  func add(menu: NSMenuItem)
  func remove(menu: NSMenuItem)
  func add(error: String)

  func submenu(didTriggerRefresh: Menuable)

  /* Legacy */
  func getValue() -> String
  func toString() -> String
}

extension Menuable {
  var params: [Param] {
    get { return container.params }
  }

  func set(title: Mutable) {
    aTitle = title
  }

  func activate() {
    /* NOP */
  }

  func add(menus: [Menu]) {
    for menu in menus {
      menu.parentable = self
      if menu.isSeparator() {
        add(menu: NSMenuItem.separator())
      } else {
        add(menu: menu)
      }
    }

    self.menus = menus
  }

  func merge(with menu: Menuable) {
    title = menu.title
    container = menu.container
    container.delegate = self
    aTitle = menu.getAttrs()
    image = menu.image
    event = menu.event
    level = menu.level
    // TODO
    //  if menu is Menu {
    //    parentable = menu.parentable
    //  }

    for pack in menus.zip(with: menu.menus) {
      switch pack {
      case let (.some(sub1), .none): /* There are less menus in the new object */
        remove(menu: sub1)
      case let (.none, .some(sub2)): /* A new menu */
        add(menu: sub2)
      case let (.some(sub1), .some(sub2)): /* Recursive merge with menu at index */
        sub1.merge(with: sub2)
      case (.none, .none):
        halt("Both can't be nil menus=\(menus), menu.menus=\(menu.menus)")
      }
    }
  }

  /**
    Replace current title with @attr
    TODO: Remove. Should be called update, not set
  */
  func update(title: String) {
    if let range = aTitle.toRange() {
      return aTitle.replaceCharacters(in: range, with: title)
    }

    update(attr: Mutable(string: title))
  }

  // TODO: Rename to set
  func update(attr: Mutable) {
    set(title: aTitle.merge(attr))
  }

  func update(attrs: [String: Any]) {
    set(title: aTitle.update(attr: attrs))
  }

  /* TODO: Rename */
  func getAttrs() -> Mutable {
    return aTitle
  }

  /* TODO: Rename */
  func getArgs() -> [String] {
    return container.args
  }

  func getTitle() -> String {
    return aTitle.string
  }

  /**
    Display an @image instead of text
  */
  func update(image anImage: NSImage, isTemplate: Bool = false) {
    image = anImage
    image?.isTemplate = isTemplate
  }

  /**
    Set the font size to @size
  */
  func update(size: Float) {
    set(title: aTitle.update(fontSize: size))
  }

  /**
    Use @color for the enture title
  */
  func update(color: NSColor) {
    update(key: NSForegroundColorAttributeName, value: color)
  }

  func update(key: String, value: Any) {
    update(attrs: [key: value])
  }

  func getValue() -> String {
    return aTitle.string
  }

  func toString() -> String {
    return getValue()
  }

  /**
    Use @fontName, i.e Times-Roman
  */
  func update(fontName: String) {
    set(title: aTitle.update(fontName: fontName))
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

  func useAsAlternate() {
    /* NOP */
  }

  func update(state: Int) {
    /* NOP */
  }
}
