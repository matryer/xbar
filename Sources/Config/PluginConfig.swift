class PluginConfig {
  private var env = [String: String]()
  private var settings = Set<Setting>()
  enum Setting: Hashable {
    case enabled(Bool)

    public var hashValue: Int {
      switch self {
      case .enabled:
        return "enabled".hashValue
      }
    }

    public static func == (lhs: Setting, rhs: Setting) -> Bool {
      switch (lhs, rhs) {
      case let (.enabled(p1), .enabled(p2)):
        return p1 == p2
      }
    }
  }

  var isEnabled: Bool {
    for case let .enabled(state) in settings {
      return state
    }

    return true
  }

  func add(env key: String, value: String) throws {
    if env[key] != nil {
      throw "\(key) has already been used"
    }

    env[key] = value
  }

  func add(_ value: Setting) throws {
    if settings.contains(value) {
      throw "\(value) has already been used"
    }
    settings.insert(value)
  }
}
