extension Menu {
  enum Tail {
    indirect case text(Text, [Param], [Tail], Action)
    indirect case image(Image, [Param], [Tail], Action)
    case error([String])
    case separator

    func add(_ tail: Tail, to level: Int) -> Tail {
      switch self {
      case .error:
        return self
      case .separator:
        return fail("Separators can't have sub menus")
      case let .text(text, params, tails, action):
        switch add(tail, to: tails, at: level) {
        case let .succ(tails):
          return .text(text, params, tails, action)
        case let .fail(message):
          return fail(message)
        }
      case let .image(image, params, tails, action):
        switch add(tail, to: tails, at: level) {
        case let .succ(tails):
          return .image(image, params, tails, action)
        case let .fail(message):
          return fail(message)
        }
      }
    }

    private func fail(_ message: String) -> Tail {
      switch self {
      case let .error(messages):
        return .error(messages + [message])
      default:
        return .error([message])
      }
    }

    private func add(_ tail: Tail, to tails: [Tail], at level: Int) -> State<[Tail], String> {
      if level == 0 {
        return .succ(tails + [tail])
      } else if level < 0 {
        return .fail("[Bug] Level is less then zero: \(level)")
      } else if tails.isEmpty {
        return .fail("No menus found for level: \(level)")
      } else {
        return .succ(tails.initial() + [tails.last!.add(tail, to: level - 1)])
      }
    }
  }
}
