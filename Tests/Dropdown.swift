import SwiftCheck
@testable import BitBar

extension Dropdown: Paramable {
  public static var arbitrary: Gen<Dropdown> {
    return Gen.compose { c in
      Dropdown(c.generate())
    }
  }

  func test(_ dropdown: Dropdown) -> Property {
    return dropdown ==== self
  }

  public static func == (lhs: Dropdown, rhs: Dropdown) -> Bool {
    return lhs.equals(rhs)
  }
}
