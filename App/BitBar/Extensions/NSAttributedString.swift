import AppKit

internal extension NSAttributedString {
  /**
    Converts @self into a mutable object
  */
  func mutable() -> NSMutableAttributedString {
    let empty = NSMutableAttributedString(withDefaultFont: "")
    empty.append(self)
    return empty
  }
}
