import Foundation
import Cent

extension String {
  func lines() -> [String] {
    return components(separatedBy: .newlines)
  }

  // TODO: Rename to something like trim or strip
  func noMore() -> String {
    return self.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func replace(_ what: String, _ with: String) -> String {
    return replacingOccurrences(of: what, with: with, options: .literal, range: nil)
  }

  func remove(_ what: String) -> String {
    return replace(what, "")
  }

  func dropLast() -> String {
    if isEmpty { return self }
    return self[0..<characters.count - 1]
  }

  func contains(_ aString: String) -> Bool {
    return range(of: aString) != nil
  }
}

extension Array {
  // func join(_ separator: String = "") -> String {
  //   return joined(separator: separator)
  // }

  // func last() -> Element? {
  //   if isEmpty { return nil }
  //   return self[count - 1]
  // }
}
