import SwiftCheck
@testable import BitBar

extension Ansi: ParamBase {
  public static var arbitrary: Gen<Ansi> {
    return Gen.compose { c in
      Ansi(c.generate())
    }
  }
}
