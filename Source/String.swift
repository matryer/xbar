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
    return "\"" + replace("\n", "↵").replace("\0", "0") + "\""
  }

  func mutable() -> Mutable {
    return Mutable(withDefaultFont: self)
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

func ini(_ sources: [Source]) -> [Source] {
  return (0..<(sources.count - 1)).map { sources[$0] }
}

enum Source {
  indirect case item((String, [Param]), Int, [Source])

  func appended(_ child: Source) -> Source {
    switch (child, self) {
    // A\n--B\n
    case let (.item(_, level1, _), .item(title, level2, children)) where level1 == level2 + 1:
      return .item(title, level2, children + [child])
    // A\n--B
    case let (.item(_, level1, _), .item(title, level2, children)) where level1 > level2:
      if children.isEmpty { return ret(failed("Can't find a parent for child: \(self), \(child)")) }
      return .item(title, level2, ini(children) + [children.last!.appended(child)])
    // --A\n--B\n
    case let (.item(_, level1, _), .item(_, level2, _)) where level1 == level2:
      return ret(failed("Can't be in the same line: \(self), \(child)"))
    // --A\nB
    case let (.item(_, level1, _), .item(_, level2, _)) where level1 < level2:
      return ret(failed("Child can't have lower level then parent: \(self), \(child)"))
    default:
      preconditionFailure("Invalid state for #appended: \(self), \(child)")
    }
  }

  func appended(_ children: [Source]) -> Source {
    return children.reduce(self) { parent, child in
      return parent.appended(child)
    }
  }

  private func failed(_ message: String) -> Source {
    switch self {
    case let .item(_, level, _):
      return .item(("[Failed] " + message, [Param]()), level, [Source]())
    }
  }

  private func ret(_ child: Source) -> Source {
    switch self {
    case let .item(title, level, children):
      return .item(title, level, children + [child])
    }
  }
}
