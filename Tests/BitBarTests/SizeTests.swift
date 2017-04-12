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
