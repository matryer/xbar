@testable import BitBar

extension Script.Failure: Equatable {
  public static func == (lhs: Script.Failure, rhs: Script.Failure) -> Bool {
    switch (lhs, rhs) {
    case let (.crash(c1), .crash(c2)):
      return c1 == c2
    case let (.exit(e1, i1), .exit(e2, i2)):
      return e1 == e2 && i1 == i2
    case let (.misuse(m1), .misuse(m2)):
      // TODO: Dont do this
      return m1.contains(m2) || m2.contains(m1)
    case (.terminated, .terminated):
      return true
    default:
      return false
    }
  }
}
