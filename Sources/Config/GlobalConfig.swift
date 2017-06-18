class GlobalConfig {
  private var settings = Set<Setting>()
  enum Setting: Hashable {
    case port(Int)
    case reloadOnConnection(Bool)

    public var hashValue: Int {
      switch self {
      case .port:
        return "port".hashValue
      case .reloadOnConnection:
        return "reloadOnConnection".hashValue
      }
    }

    public static func == (lhs: Setting, rhs: Setting) -> Bool {
      switch (lhs, rhs) {
      case let (.port(p1), .port(p2)):
        return p1 == p2
      case let (.reloadOnConnection(p1), .reloadOnConnection(p2)):
        return p1 == p2
      default:
        return false
      }
    }
  }

  func add(_ value: Setting) throws {
    if settings.contains(value) {
      throw "\(value) has already been used"
    }
    settings.insert(value)
  }

  var port: Int {
    for case let .port(value) in settings {
      return value
    }

    return 8080
  }

  var reloadOnConnection: Bool {
    for case let .reloadOnConnection(value) in settings {
      return value
    }

    return true
  }
}
