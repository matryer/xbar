import SwiftCheck
@testable import BitBar

extension Href: Paramable {
  public var attribute: String { return "href" }

  public static var arbitrary: Gen<Href> {
    return Gen.compose { c in
      Href(c.generate(using: aWord()))
    }
  }

  func test(_ href: Href) -> Property {
    return href.getValue() ==== self.getValue()
  }
}
