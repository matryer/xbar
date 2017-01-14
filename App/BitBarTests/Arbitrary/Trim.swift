import SwiftCheck
@testable import BitBar

extension Trim: Paramable {
  public var attribute: String { return "trim" }

  public static var arbitrary: Gen<Trim> {
    return Gen.compose { c in
      Trim(c.generate())
    }
  }

  func test(_ trim: Trim) -> Property {
    return trim.getValue() ==== self.getValue()
  }
}
