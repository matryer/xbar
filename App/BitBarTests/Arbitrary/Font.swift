import SwiftCheck
@testable import BitBar

extension Font: Paramable {
  public static var arbitrary: Gen<Font> {
    return Gen.compose { c in
      Font(c.generate())
    }
  }

  func test(_ font: Font) -> Property {
    return font ==== self
  }

  public static func == (lhs: Font, rhs: Font) -> Bool {
    return lhs.equals(rhs)
  }
}
