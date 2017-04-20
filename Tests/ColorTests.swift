import Quick
import Nimble
import Attr
@testable import BitBar

class ColorTests: Helper {
  override func spec() {
    describe("parser") {
      describe("english") {
        it("handels base case") {
          self.match(Pro.getColor(), "color=red") {
            expect($0).to(equal("red"))
          }
        }
      }

      describe("hex") {
        it("handels base case") {
          self.match(Pro.getColor(), "color=#00AA11") {
            expect($0).to(equal("#00AA11"))
          }
        }
      }
    }
  }
}
