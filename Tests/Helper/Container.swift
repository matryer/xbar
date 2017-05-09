import Cocoa

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

  func items() -> [NSMenuItem] {
    switch self {
    case let .success(menu):
      if let that = menu as? Menuable {
        return that.items
      }

      return []
    default:
      return []
    }
  }
}

