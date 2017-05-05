@testable import BitBar
import AppKit

class TestBar: Menubarable {
  var menu: NSMenu?
  var attributedTitle: NSAttributedString?
  var highlightMode: Bool = false
  func show() {}
  func hide() {}
}
