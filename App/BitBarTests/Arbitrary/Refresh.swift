import SwiftCheck
@testable import BitBar

extension Refresh: Paramable {
  public var attribute: String { return "refresh" }

  public static var arbitrary: Gen<Refresh> {
    return Gen.compose { c in
      Refresh(c.generate())
    }
  }

  func test(_ refresh: Refresh) -> Property {
    return refresh.getValue() ==== self.getValue()
  }
}
