enum Menu {
  enum Head {
    case text(Text, [Tail])
    case error([String])

    private func fail(_ message: String) -> Head {
      switch self {
      case .text:
        return .error([message])
      case let .error(messages):
        return .error(messages + [message])
      }
    }

    private func reduce(_ tail: Tail, to level: Int) -> Head {
      switch (self, level) {
      case (.error, _):
        return self
      case let (.text(text, tails), 0):
        return .text(text, tails + [tail])
      case let (.text(_, tails), _) where tails.isEmpty:
        return fail("Child belongs to level \(level) which doesn't exist: \(tail)")
      case let (.text(text, tails), _) where level > 0:
        return .text(text, tails.initial() + [tails.last!.add(tail, to: level - 1)])
      case (.text, _):
        return fail("[Bug] Level can't be negative: \(level)")
      }
    }

    func add(_ tail: Tail, to level: Int) -> Head {
      switch (tail, level) {
      case (.separator, 0):
        return reduce(tail, to: 0)
      case (.separator, _):
        return reduce(tail, to: level - 1)
      default:
        return reduce(tail, to: level)
      }
    }
  }
}
