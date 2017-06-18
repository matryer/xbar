import AppKit

extension NSAttributedString {
  /**
    Converts @self into a mutable object
  */
  var mutable: NSMutableAttributedString {
    return NSMutableAttributedString(attributedString: self)
  }
}
