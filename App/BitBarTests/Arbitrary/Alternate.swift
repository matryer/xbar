import SwiftCheck
@testable import BitBar

extension Alternate: Paramable {
  public var attribute: String { return "alternate" }

  public static var arbitrary: Gen<Alternate> {
    return Gen.compose { c in
      Alternate(c.generate())
    }
  }

  func test(_ alternate: Alternate) -> Property {
    return alternate.getValue() ==== self.getValue()
  }
}
