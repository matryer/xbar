import SwiftCheck
@testable import BitBar

extension Font: Paramable {
  public var attribute: String { return "font" }

  public static var arbitrary: Gen<Font> {
    return Gen.compose { c in
      Font(c.generate(using: aWord()))
    }
  }

  func test(_ font: Font) -> Property {
    return font.getValue() ==== self.getValue()
  }
}
