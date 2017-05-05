@testable import BitBar

extension Script {
  enum Result {
    case success(Success)
    case failure(Failure)
  }
}
