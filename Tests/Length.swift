import SwiftCheck
@testable import BitBar

extension Length: Paramable {
  static let number: Gen<Int> = Gen<Int>.fromElements(in: 1000...10000)

  public static var arbitrary: Gen<Length> {
    return Gen.compose { c in
      Length(c.generate(using: number))
    }
  }

  func test(_ length: Length) -> Property {
    return length ==== self
  }

  public static func == (lhs: Length, rhs: Length) -> Bool {
    return lhs.equals(rhs)
  }
}
