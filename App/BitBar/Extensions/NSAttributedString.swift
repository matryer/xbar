import AppKit

internal extension NSAttributedString {
  func mutable() -> NSMutableAttributedString {
    let empty = NSMutableAttributedString(withDefaultFont: "")
    empty.append(self)
    return empty
  }
}
