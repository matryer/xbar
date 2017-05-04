import Quick
import Nimble
import SwiftCheck
@testable import BitBarParser

class ColorTests: QuickSpec {
  override func spec() {
    it("tests color") {
      property("color") <- forAll(Color.arbitrary) { color in
        switch Pro.parse(Pro.color, color.output) {
        case let .success(.color(other)):
          return color ==== other
        case let .failure(error):
          return false <?> String(describing: error)
        case let .success(that):
          return false <?> "\(that) is not a color"
        }
      }
    }
  }
}
