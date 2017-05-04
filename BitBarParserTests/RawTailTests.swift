import Quick
import Nimble
import SwiftCheck
@testable import BitBarParser

class RawTailTests: QuickSpec {
  override func spec() {
    it("handles raw tail") {
      property("raw tail") <- forAll { (tail: Raw.Tail) in
        switch Pro.parse(Pro.menu, tail.output) {
          case let .success(menu):
            return menu ==== tail
          case let .failure(error):
            return false <?> String(describing: error)
         }
       }
     }
  }
}
