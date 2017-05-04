import SwiftCheck
@testable import BitBarParser

extension Color: CustomStringConvertible {
  public static func ==== (lhs: Color, rhs: Color) -> Property {
    switch (lhs, rhs) {
    case let (.name(s1), .name(s2)):
      return s1 ==== s2
    case let (.hex(c1), .hex(c2)):
      return c1 ==== c2
    default:
      return false <?> "color: \(lhs) != \(rhs)"
    }
  }

  public var description: String {
    return output
  }
}
