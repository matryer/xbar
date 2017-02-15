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
  func getAttrs() -> Mutable
  func onDidClick(block: @escaping Block<Void>) -> Listener
  func useAsAlternate()
  func activate()
  func set(title: String)
  func set(title: Mutable)
  func refresh()
  func getArgs() -> [String]
  func openTerminal() -> Bool
  func shouldRefresh() -> Bool
  func set(state: Int)
  func set(color: NSColor)
  func set(fontName: String)
  func set(size: Float)
  func set(image: NSImage, isTemplate: Bool)
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

  func set(title: String) {
    aTitle = title.mutable()
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
    // TODO: [IMP]
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
  func set(image anImage: NSImage, isTemplate: Bool = false) {
    anImage.isTemplate = isTemplate
    image = anImage
  }

  /**
    Set the font size to @size
  */
  func set(size: Float) {
    set(title: aTitle.update(fontSize: size))
  }

  /**
    Use @color for the enture title
  */
  func set(color: NSColor) {
    set(title: aTitle.style(with: .foreground(color)))
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
  func set(fontName: String) {
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

  func set(state: Int) {
    /* NOP */
  }
}
