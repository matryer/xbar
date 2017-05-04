@testable import BitBarParser
import SwiftCheck

extension Text: CustomStringConvertible {
  public var description: String {
    return output
  }

  static func ==== (title: String, text: Text) -> Property {
    return title ==== text.title
  }
}
