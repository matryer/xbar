import SwiftCheck
@testable import BitBar

extension Terminal: Paramable {
  public static var arbitrary: Gen<Terminal> {
    return Gen.compose { c in
      Terminal(c.generate())
    }
  }

  func test(_ terminal: Terminal) -> Property {
    return terminal ==== self
  }

  public static func == (lhs: Terminal, rhs: Terminal) -> Bool {
    return lhs.equals(rhs)
  }
}
