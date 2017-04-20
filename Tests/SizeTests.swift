import Quick
import Attr
import Nimble
@testable import BitBar

class SizeTests: Helper {
  override func spec() {
    it("handles base case") {
      expect(input("size=12", with: Pro.getSize())).to(output("12"))
    }

    context("failures") {
      it("fails on negative numbers") {
        self.failure(Pro.getSize(), "size=-10")
      }

      it("fails on zero") {
        self.failure(Pro.getSize(), "size=0")
      }

      it("fails on blank") {
        self.failure(Pro.getSize(), "size=")
      }

      it("fails on empty") {
        self.failure(Pro.getSize(), "size=     ")
      }

      it("fails on non numbers") {
        self.failure(Pro.getSize(), "size=X")
      }
    }
  }
}
