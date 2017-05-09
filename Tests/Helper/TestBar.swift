@testable import BitBar
import AppKit

class TestBar: MenuBar {
  var menu: NSMenu?
  var attributedTitle: NSAttributedString?
  var highlightMode: Bool = false
  func show() {}
  func hide() {}
}
