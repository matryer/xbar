import SwiftCheck
@testable import BitBar

extension Terminal: Paramable {
  public var attribute: String { return "terminal" }

  public static var arbitrary: Gen<Terminal> {
    return Gen.compose { c in
      Terminal(c.generate())
    }
  }

  func test(_ terminal: Terminal) -> Property {
    return terminal.getValue() ==== self.getValue()
  }
}
