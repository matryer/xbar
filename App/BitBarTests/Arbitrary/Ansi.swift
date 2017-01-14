import SwiftCheck
@testable import BitBar

extension Ansi: Paramable {
  public var attribute: String { return "ansi" }

  public static var arbitrary: Gen<Ansi> {
    return Gen.compose { c in
      Ansi(c.generate())
    }
  }

  func test(_ ansi: Ansi) -> Property {
    return ansi.getValue() ==== self.getValue()
  }
}
