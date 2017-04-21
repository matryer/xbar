extension Script.Failure: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .crash(message):
      return "Crashed: \(message)"
    case let .exit(message, status):
      return "Failed (\(status)): \(message.inspected())"
    case let .misuse(message):
      return "Misused (2): \(message.inspected())"
    case .terminated():
      return "Terminated (15): Manual termination using Script#stop"
    }
  }
}
