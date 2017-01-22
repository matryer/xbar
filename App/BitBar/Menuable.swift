import Cocoa
import EmitterKit

protocol Menuable: class {
  var aTitle: NSMutableAttributedString { get set }
  var image: NSImage? { get set }
  var container: Container { get }
  var title: String { get }
  var events: [Listener] { get set }
  var refreshEvent: Event<Void> { get set }
  var menus: [Menu] { get set }

  func getTitle() -> String
  func getAttrs() -> NSMutableAttributedString
  func onDidClick(block: @escaping () -> Void)
  func useAsAlternate()
  func refresh()
  func getArgs() -> [String]
  func openTerminal() -> Bool
  func shouldRefresh() -> Bool
  func onDidRefresh(block: @escaping () -> Void)
  func update(attr: NSMutableAttributedString)
  func update(state: Int)
  func update(color: NSColor)
  func update(fontName: String)
  func update(size: Float)
  func update(image: NSImage, isTemplate: Bool)
  func update(title: String)
  func add(menu: NSMenuItem)
  func add(params: [Param])

  /* Legacy */
  func getValue() -> String
  func toString() -> String
}

extension Menuable {
  var params: [Param] {
    get { return container.params }
  }

  func set(title: NSMutableAttributedString) {
    aTitle = title
  }

  func add(params: [Param]) {
    container.delegate = self
    container.append(params: params)
    container.apply()
  }

  func add(menus: [Menu]) {
    for menu in menus {
      if menu.isSeparator() {
        add(menu: NSMenuItem.separator())
      } else {
        add(menu: menu)
      }
    }
    self.menus = menus
  }

  /**
    @block is invoked when refresh=true and child
    menu item has finished loading
  */
  func onDidRefresh(block: @escaping () -> Void) {
    events.append(refreshEvent.on(block))
  }

  /**
    Replace current title with @attr
    // TODO: Remove. Should be called update, not set
  */
  func update(title: String) {
    update(attr: NSMutableAttributedString(string: title))
  }

  // TODO: Rename to set
  func update(attr: NSMutableAttributedString) {
    set(title: aTitle.merge(attr))
  }

  func update(attrs: [String: Any]) {
    set(title: aTitle.update(attr: attrs))
  }

  /* TODO: Rename */
  func getAttrs() -> NSMutableAttributedString {
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

  func refresh() {
    /* NOP */
  }

  func onDidClick(block: @escaping () -> Void) {
    /* NOP */
  }

  func useAsAlternate() {
    /* NOP */
  }

  func update(state: Int) {
    /* NOP */
  }
}
