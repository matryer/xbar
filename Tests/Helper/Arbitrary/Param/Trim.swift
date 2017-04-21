import SwiftCheck
@testable import BitBar

extension Trim: ParamBase {
  public static var arbitrary: Gen<Trim> {
    return Gen.compose { c in
      Trim(c.generate())
    }
  }
}
