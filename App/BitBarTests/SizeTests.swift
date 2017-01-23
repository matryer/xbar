import Quick
import Nimble
@testable import BitBar

class SizeTests: Helper {
  override func spec() {
    it("handles base case") {
      self.match(Pro.getSize(), "size=12") {
        expect($0.getValue()).to(equal(12))
      }
    }
  }
}
