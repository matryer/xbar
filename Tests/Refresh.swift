import SwiftCheck
@testable import BitBar

extension Refresh: ParamBase {
  public static var arbitrary: Gen<Refresh> {
    return Gen.compose { c in
      Refresh(c.generate())
    }
  }
}
