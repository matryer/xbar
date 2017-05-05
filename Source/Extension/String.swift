import Foundation
import Dollar

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

  var mutable: Mutable {
    return Mutable(withDefaultFont: self)
  }
}
