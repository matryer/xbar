import AppKit

// Represents an instance of NSStatusBarItem
protocol MenuBar {
  var menu: NSMenu? { get set }
  var attributedTitle: NSAttributedString? { get set }
  var highlightMode: Bool { get set }
  var button: NSStatusBarButton? { get }
  var tag: String? { get set }
  func show()
  func hide()
}
