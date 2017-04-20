import SwiftCheck
@testable import BitBar

extension Length: ParamBase {
  static let number: Gen<Int> = Gen<Int>.fromElements(in: 1000...10000)

  public static var arbitrary: Gen<Length> {
    return Gen.compose { c in
      Length(c.generate(using: number))
    }
  }
}
