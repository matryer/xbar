import Quick
import Nimble
import SwiftCheck
@testable import BitBarParser

class ImageTests: QuickSpec {
  override func spec() {
    it("handles image") {
      property("image") <- forAll { (image: Image) in
        switch Pro.parse(Pro.image, image.output) {
        case let .success(param):
          return .image(image) ==== param
        case let .failure(error):
          return false <?> String(describing: error)
        }
      }
    }
  }
}
