import SwiftCheck
@testable import BitBar

extension Emojize: Paramable {
  public var attribute: String { return "emojize" }

  public static var arbitrary: Gen<Emojize> {
    return Gen.compose { c in
      Emojize(c.generate())
    }
  }

  func test(_ emojize: Emojize) -> Property {
    return emojize.getValue() ==== self.getValue()
  }
}
