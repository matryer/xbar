import SwiftCheck
@testable import BitBar

extension Href: Paramable {
  public static var arbitrary: Gen<Href> {
    return Gen.compose { c in
      Href(c.generate())
    }
  }

  func test(_ href: Href) -> Property {
    return href ==== self
  }

  public static func == (lhs: Href, rhs: Href) -> Bool {
    return lhs.equals(rhs)
  }
}
