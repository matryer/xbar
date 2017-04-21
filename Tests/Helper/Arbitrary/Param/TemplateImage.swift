import SwiftCheck
@testable import BitBar

extension TemplateImage {
  public static var arbitrary: Gen<TemplateImage> {
    return Gen.compose { c in
      TemplateImage(c.generate(using: base64))
    }
  }
}
