import SwiftCheck
@testable import BitBar

extension Trim: Paramable {
  public static var arbitrary: Gen<Trim> {
    return Gen.compose { c in
      Trim(c.generate())
    }
  }

  func test(_ trim: Trim) -> Property {
    return trim ==== self
  }

  public static func == (lhs: Trim, rhs: Trim) -> Bool {
    return lhs.equals(rhs)
  }
}
