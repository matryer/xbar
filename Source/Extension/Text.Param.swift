import Parser

extension Text.Param: Comparable {
  public static func < (lhs: Text.Param, rhs: Text.Param) -> Bool {
    switch (lhs, rhs) {
    case (.ansi, _):
      return true
    case (.emojize, .ansi):
      return false
    case (.emojize, _):
      return true
    default:
      return false
    }
  }
}
