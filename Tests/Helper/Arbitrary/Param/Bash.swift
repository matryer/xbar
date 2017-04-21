import SwiftCheck
@testable import BitBar

extension Bash: ParamBase {
  public static var arbitrary: Gen<Bash> {
    return Gen.compose { c in
      Bash(c.generate(using: String.any(empty: false)))
    }
  }
}
