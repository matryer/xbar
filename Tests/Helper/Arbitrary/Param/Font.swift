import SwiftCheck
import AppKit
import Attr

@testable import BitBar

extension Font: ParamBase {
  private static let fonts: [String] = NSFontManager.shared().availableFontFamilies
  private static let font = Gen<String>.choose((0, fonts.count - 1)).map { fonts[$0] }

  public static var arbitrary: Gen<Font> {
    return Gen.compose { Font($0.generate(using: font)) }
  }
}
