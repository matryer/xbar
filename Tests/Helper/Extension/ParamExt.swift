import Foundation
@testable import BitBar

extension Param: Equatable {
  public static func ==<T> (lhs: Param<T>, rhs: Param<T>) -> Bool {
    return lhs.output == rhs.output
  }
}

