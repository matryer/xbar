import SwiftCheck
@testable import BitBar

extension Alternate: ParamBase {
  public static var arbitrary: Gen<Alternate> {
    return Gen.compose { c in
      Alternate(c.generate())
    }
  }
}
