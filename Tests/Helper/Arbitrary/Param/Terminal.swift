import SwiftCheck
@testable import BitBar

extension Terminal: ParamBase {
  public static var arbitrary: Gen<Terminal> {
    return Gen.compose { c in
      Terminal(c.generate())
    }
  }
}
