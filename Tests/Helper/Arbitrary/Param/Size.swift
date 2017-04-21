import SwiftCheck
@testable import BitBar

extension Size: ParamBase {
  public static var arbitrary: Gen<Size> {
    return Gen.compose { c in
      Size(c.generate(using: natrual))
    }
  }
}
