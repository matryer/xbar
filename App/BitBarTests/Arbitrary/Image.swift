import SwiftCheck
@testable import BitBar

extension Image: Paramable {
  public var attribute: String { return "image" }

  public static var arbitrary: Gen<Image> {
    return Gen.compose { c in
      Image(c.generate(using: base64) as String)
    }
  }

  func test(_ image: Image) -> Property {
    return image.getValue() ==== self.getValue()
  }
}
