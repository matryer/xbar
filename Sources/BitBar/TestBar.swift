import AppKit

class TestBar: MenuBar {
  var button: NSStatusBarButton? {
    return nil
  }
  var menu: NSMenu?
  var attributedTitle: NSAttributedString?
  var highlightMode: Bool = false
  func show() {}
  func hide() {}
}
