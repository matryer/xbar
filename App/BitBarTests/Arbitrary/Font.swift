import SwiftCheck
@testable import BitBar

extension Font: Paramable {
  private static let fonts = NSFontManager.shared().availableFontFamilies
  private static let font = Gen<String>.choose((0, fonts.count - 1)).map { fonts[$0] }

  public static var arbitrary: Gen<Font> {
    return Gen.compose { Font($0.generate(using: font)) }
  }

  func test(_ font: Font) -> Property {
    return font ==== self
  }

  public static func == (lhs: Font, rhs: Font) -> Bool {
    return lhs.equals(rhs)
  }
}
