import AppKit

class TestBar: MenuBar {
  var tag: String? {
    get { return "TestBar" }
    set { }
  }

  var button: NSStatusBarButton? { return nil }
  var menu: NSMenu?
  var attributedTitle: NSAttributedString?
  var highlightMode: Bool = false
  func show() {}
  func hide() {}
}
