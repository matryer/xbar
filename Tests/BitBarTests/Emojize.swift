import SwiftCheck
@testable import BitBar

extension Emojize: Paramable {
  public static var arbitrary: Gen<Emojize> {
    return Gen.compose { c in
      Emojize(c.generate())
    }
  }

  func test(_ emojize: Emojize) -> Property {
    return emojize ==== self
  }

  public static func == (lhs: Emojize, rhs: Emojize) -> Bool {
    return lhs.equals(rhs)
  }
}
