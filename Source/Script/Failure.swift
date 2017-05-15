extension Script {
  enum Failure: CustomStringConvertible {
    case crash(String)
    case exit(String, Int)
    case misuse(String)
    case notFound
    case notExec
    case terminated

    public var description: String {
      switch self {
      case let .crash(message):
        return "Crashed: \(message)"
      case let .exit(message, status):
        return "Failed (\(status)): \(message.inspected())"
      case let .misuse(message):
        return "Misused (2): \(message.inspected())"
      case .terminated:
        return "Terminated (15): Manual termination using Script#stop"
      case .notFound:
        return "Not Found (127): Executable not found, verify the file path"
      case .notExec:
        return "Not Executable (126): File is not executable, did you run chmod +x on it?"
      }
    }
  }
}
