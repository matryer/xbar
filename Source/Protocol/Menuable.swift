import Cocoa
import EmitterKit

protocol Menuable: class {
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
