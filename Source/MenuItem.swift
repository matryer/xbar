import AppKit

protocol MenuItem: class, Parent {
  var image: NSImage? { get set }
  func onDidClick()
}

extension MenuItem {
  func onDidClick() { }
}
