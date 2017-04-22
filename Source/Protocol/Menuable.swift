import Cocoa
import EmitterKit

protocol Menuable: class {
  var args: [String] { get set }
  var listener: Listener? { get set }
  var sortedParams: [Paramable] { get }
  var level: Int { get set }
  var headline: NSMutableAttributedString { get set }
  var image: NSImage? { get set }
  var isEnabled: Bool { get }
  var items: [NSMenuItem] { get }
  var isAltAlternate: Bool { get }
  var isChecked: Bool { get }
  var menus: [Menu] { get }
  var event: Event<Void> { get set }
  var params: [Paramable] { get set }
  var openInTerminal: Bool { get }
  func isSeparator() -> Bool
  func hideDropdown()
  func onDidClick(block: @escaping Block<Void>) -> Listener
  func useAsAlternate()
  func activate()
  func refresh()
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
  func submenu(didTriggerRefresh: Menuable)
}
