import SwiftCheck
@testable import BitBar

extension TemplateImage: Paramable {
  public var attribute: String { return "templateImage" }

  public static var arbitrary: Gen<TemplateImage> {
    return Gen.compose { c in
      TemplateImage(c.generate(using: base64))
    }
  }

  func test(_ templateImage: TemplateImage) -> Property {
    return templateImage.getValue() ==== self.getValue()
  }
}
