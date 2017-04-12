import SwiftCheck
@testable import BitBar

extension Alternate: Paramable {
  public static var arbitrary: Gen<Alternate> {
    return Gen.compose { c in
      Alternate(c.generate())
    }
  }

  func test(_ alternate: Alternate) -> Property {
    return alternate ==== self
  }

  public static func == (lhs: Alternate, rhs: Alternate) -> Bool {
    return lhs.equals(rhs)
  }
}
