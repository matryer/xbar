import SwiftCheck
@testable import BitBar

extension TemplateImage: Paramable {
  public static var arbitrary: Gen<TemplateImage> {
    return Gen.compose { c in
      TemplateImage(c.generate(using: base64))
    }
  }

  func test(_ templateImage: TemplateImage) -> Property {
    return templateImage ==== self
  }

  public static func == (lhs: TemplateImage, rhs: TemplateImage) -> Bool {
    return lhs.equals(rhs)
  }
}
