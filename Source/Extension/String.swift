import Foundation
import Dollar

enum FontType: String {
  case bar
  case item
  var font: NSFont {
    switch self {
    case .bar:
      return NSFont.menuBarFont(ofSize: 16)
    case .item:
      return NSFont.menuFont(ofSize: 0)
    }
  }

  var size: Float {
    return Float(font.pointSize)
  }
}

extension String {
  /**
    Remove surrounding whitespace
  */
  func trimmed() -> String {
    return trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /**
    Replace @what with @with in @self
  */
  func replace(_ what: String, _ with: String) -> String {
    return replacingOccurrences(of: what, with: with, options: .literal, range: nil)
  }

  /**
    Remove all occurrences of @what in @self
  */
  func remove(_ what: String) -> String {
    return replace(what, "")
  }

  func inspected() -> String {
    return "\"" + replace("\n", "↵") + "\""
  }

  func toData() -> Data {
    return data(using: .utf8)!
  }

  func mutable() -> Mutable {
    return Mutable(string: self)
  }

  var immutable: Immutable {
    return Immutable(string: self)
  }
}
