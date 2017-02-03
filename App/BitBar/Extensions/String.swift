import Foundation
import Swift

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

  func inspected() -> String {
    return "\"" + replace("\n", "↵") + "\""
  }

  func mutable() -> NSMutableAttributedString {
    return NSMutableAttributedString(withDefaultFont: self)
  }

  var camelCase: String {
    if isEmpty { return self }
    return substring(to: 1).lowercased() + substring(from: 1)
  }

  func index(from: Int) -> Index {
    return self.index(startIndex, offsetBy: from)
  }

  func substring(from: Int) -> String {
    let fromIndex = index(from: from)
    return substring(from: fromIndex)
  }

  func substring(to: Int) -> String {
    let toIndex = index(from: to)
    return substring(to: toIndex)
  }

  func substring(with r: Range<Int>) -> String {
    let startIndex = index(from: r.lowerBound)
    let endIndex = index(from: r.upperBound)
    return substring(with: startIndex..<endIndex)
  }
}

enum Source {
  indirect case item((String, [Param]), Int, [Source])
}
