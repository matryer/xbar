import SwiftCheck
@testable import BitBar

extension Refresh: Paramable {
  public static var arbitrary: Gen<Refresh> {
    return Gen.compose { c in
      Refresh(c.generate())
    }
  }

  func test(_ refresh: Refresh) -> Property {
    return refresh ==== self
  }

  public static func == (lhs: Refresh, rhs: Refresh) -> Bool {
    return lhs.equals(rhs)
  }
}
