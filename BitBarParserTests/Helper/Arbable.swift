import SwiftCheck

protocol Arbable: Arbitrary {
  static func ==== (lhs: Self, rhs: Self) -> Property
  var output: String { get }
}
