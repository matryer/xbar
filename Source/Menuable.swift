import Cocoa
import EmitterKit

protocol Menuable: class  {
  var level: Int { get set }
  var aTitle: NSMutableAttributedString { get set }
  var image: NSImage? { get set }
  var container: Container { get set }
  var isEnabled: Bool { get }
  var title: String { get set }
  var hasDropdown: Bool { get }
  var items: [NSMenuItem] { get }
  var isAltAlternate: Bool { get }
  var isChecked: Bool { get }
  var menus: [Menu] { get }
  var event: Event<Void> { get set }
  func isSeparator() -> Bool
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
  func remove(menu: Menu)
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

  internal var menus: [Menu] {
    return items.reduce([Menu]()) { acc, menu in
      switch menu {
      case is Menu:
        return acc + [menu as! Menu]
      default:
        if menu.isSeparatorItem {
          return acc + [Menu(isSeparator: true)]
        }

        preconditionFailure("[Bug] Invalid class \(menu)")
      }
    }
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
    guard hasDropdown else { return }
    for menu in menus {
      menu.parentable = self
      if menu.isSeparator() {
        add(menu: NSMenuItem.separator())
      } else {
        add(menu: menu)
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
