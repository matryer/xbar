import Foundation
import Cent
import GameKit

extension String {
  /**
    Remove surrounding whitespace
  */
  func trim() -> String {
    return self.trimmingCharacters(in: .whitespacesAndNewlines)
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

  /**
    Remove the last character, unless string is empty
  */
  func dropLast() -> String {
    if isEmpty { return self }
    return self[0..<characters.count - 1]
  }

  func inspecting() -> String {
    if isEmpty { return "NOP" }
    return "'" + replace("\n", "\\n").replace("'", "\\'") + "'"
  }
}

extension Array {
  func shuffle() -> [Any] {
    if #available(OSX 10.11, *) {
      return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self)
    } else {
      return self // TODO: Implement
    }
  }
}
