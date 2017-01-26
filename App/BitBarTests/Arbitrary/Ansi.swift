import SwiftCheck
@testable import BitBar

extension Ansi: Paramable {
  public static var arbitrary: Gen<Ansi> {
    return Gen.compose { c in
      Ansi(c.generate())
    }
  }

  func test(_ ansi: Ansi) -> Property {
    return ansi ==== self
  }

  public static func == (lhs: Ansi, rhs: Ansi) -> Bool {
    return lhs.equals(rhs)
  }
}
