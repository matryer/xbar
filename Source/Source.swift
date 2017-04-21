enum Source {
  indirect case item((String, [Paramable]), Int, [Source])

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
      return .item(("[Failed] " + message, [Paramable]()), level, [Source]())
    }
  }

  private func ret(_ child: Source) -> Source {
    switch self {
    case let .item(title, level, children):
      return .item(title, level, children + [child])
    }
  }

  private func ini(_ sources: [Source]) -> [Source] {
    return (0..<(sources.count - 1)).map { sources[$0] }
  }
}
