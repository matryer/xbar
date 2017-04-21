public enum W<T>: CustomStringConvertible {
  case success(T)
  case failure

  public var description: String {
    switch self {
    case let .success(output):
      return String(describing: output)
    default:
      return "[Failed]"
    }
  }
}
