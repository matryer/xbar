import Cocoa
import EmitterKit

protocol Menuable: class  {
  var args: [String] { get set }
  var listener: Listener? { get set }
  var level: Int { get set }
  var headline: NSMutableAttributedString { get set }
  var image: NSImage? { get set }
  var isEnabled: Bool { get }
  var hasDropdown: Bool { get }
  var items: [NSMenuItem] { get }
  var isAltAlternate: Bool { get }
  var isChecked: Bool { get }
  var menus: [Menu] { get }
  var event: Event<Void> { get set }
  var params: [Paramable] { get set }
  var settings: [String: Bool] { get set }
  func isSeparator() -> Bool
  func load()
  func onDidClick(block: @escaping Block<Void>) -> Listener
  func useAsAlternate()
  func activate()
  func refresh()
  func openTerminal() -> Bool
  func shouldRefresh() -> Bool
  func shouldTrim() -> Bool
  func set(state: Int)
  func set(color: NSColor)
  func set(fontName: String)
  func set(size: Float)
  func add(arg: String)
  func set(image: NSImage, isTemplate: Bool)
  func set(headline: String)
  func set(headline: Mutable)
  func add(error: String)
  func add(menu: NSMenuItem)
  func setting(terminal: Bool)
  func setting(dropdown: Bool)
  func setting(refresh: Bool)
  func setting(trim: Bool)
  func submenu(didTriggerRefresh: Menuable)
}

extension Menuable {
  func setting(terminal: Bool) {
    settings["terminal"] = terminal
  }

  func setting(refresh: Bool) {
    settings["refresh"] = refresh
  }

  func setting(dropdown: Bool) {
    settings["dropdown"] = dropdown
  }

  func setting(trim: Bool) {
    settings["trim"] = trim
  }

  func shouldTrim() -> Bool {
    return settings["trim"] ?? true
  }

  func add(arg: String) {
    args.append(arg)
  }

  func load() {
    let those = params.sorted { a, b in
      return a.priority > b.priority
    }

    for param in those {
      param.menu(didLoad: self)
    }

   listener = onDidClick {
     for param in those {
       param.menu(didClick: self)
     }
   }
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

  func set(headline: Mutable) {
    self.headline = headline
  }

  func set(headline: String) {
    set(headline: headline.mutable())
  }

  func activate() {
    set(state: NSOnState)
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
    set(headline: headline.update(fontSize: size))
  }

  /**
    Use @color for the enture title
  */
  func set(color: NSColor) {
    set(headline: headline.style(with: .foreground(color)))
  }

  /**
    Use @fontName, i.e Times-Roman
  */
  func set(fontName: String) {
    set(headline: headline.update(fontName: fontName))
  }

  func add(error: String) {
    set(headline: ":warning: \(error)".emojifyed())
  }
}
