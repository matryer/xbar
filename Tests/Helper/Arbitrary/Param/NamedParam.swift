import SwiftCheck
@testable import BitBar

extension NamedParam: ParamBase {
  static let head: Gen<Int> = (0...10000).any

  public static var arbitrary: Gen<NamedParam> {
    return Gen.compose { c in
      return NamedParam(c.generate(using: head), c.generate(using: String.any(min: 1)))
    }
  }
}
