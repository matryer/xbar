import AppKit

protocol Menubarable {
  var menu: NSMenu? { get set }
  var attributedTitle: NSAttributedString? { get set }
  var highlightMode: Bool { get set }
  func show()
  func hide()
}
