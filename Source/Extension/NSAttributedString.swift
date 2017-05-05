import AppKit
import Attr

internal extension NSAttributedString {
  /**
    Converts @self into a mutable object
  */
  func mutable() -> NSMutableAttributedString {
    return NSMutableAttributedString(attributedString: self)
  }
}
