import Quick
import Nimble
import Attr
@testable import BitBar

class LengthTests: Helper {
  override func spec() {
    context("base case") {
      it("handels base case") {
        let menu = Menu("hello")
        let length = Length(1)
        length.menu(didLoad: menu)
        expect(menu.title).to(equal("h…"))
      }
    }

    context("parser") {
      let parser = Pro.getLength()

      it("handles positive value") {
        expect(input("length=10", with: parser)).to(output("10"))
      }

      it("handles leading zeros") {
        expect(input("length=05", with: parser)).to(output("5"))
      }

      context("invalid values") {
        it("fails on negative values") {
          self.failure(parser, "length=-2")
        }

        it("fails on no value") {
          self.failure(parser, "length=")
        }

        it("fails on floats") {
          self.failure(parser, "length=10.0")
        }
      }
  }
  }
}
