@testable import BitBar

extension Script.Success: Equatable {
  public static func == (lhs: Script.Success, rhs: Script.Success) -> Bool {
    return lhs.status == rhs.status && lhs.output == rhs.output
  }
}
