import SwiftCheck
@testable import BitBar

extension Dropdown: Paramable {
  public var attribute: String { return "dropdown" }

  public static var arbitrary: Gen<Dropdown> {
    return Gen.compose { c in
      Dropdown(c.generate())
    }
  }

  func test(_ dropdown: Dropdown) -> Property {
    return dropdown.getValue() ==== self.getValue()
  }
}
