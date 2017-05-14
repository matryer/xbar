@testable import BitBar

enum Std: Equatable {
  case succ(Script.Success)
  case fail(Script.Failure)

  public static func == (rhs: Std, lhs: Std) -> Bool {
    switch (rhs, lhs) {
    case let (.succ(s1), .succ(s2)):
      return s1 == s2
    case let (.fail(s1), .fail(s2)):
      return s1 == s2
    default:
      return false
    }
  }
}
