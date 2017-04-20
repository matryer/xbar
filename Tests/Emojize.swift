import SwiftCheck
@testable import BitBar

extension Emojize: ParamBase {
  public static var arbitrary: Gen<Emojize> {
    return Gen.compose { c in
      Emojize(c.generate())
    }
  }
}
