import SwiftCheck
@testable import BitBar

extension Dropdown: ParamBase {
  public static var arbitrary: Gen<Dropdown> {
    return Gen.compose { c in
      Dropdown(c.generate())
    }
  }
}
