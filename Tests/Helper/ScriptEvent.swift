enum ScriptEvent: Equatable {
  case termination
  case success
  case unknown(String)

  public static func == (lhs: ScriptEvent, rhs: ScriptEvent) -> Bool {
    switch (lhs, rhs) {
    case (.termination, .termination):
      return true
    case (.success, .success):
      return true
    case let (.unknown(a1), .unknown(a2)):
      return a1 == a2
    default:
      return false
    }
  }
}
