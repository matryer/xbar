import Quick
import Nimble
@testable import BitBar

class OutputTests: Helper {
  override func spec() {
    describe("output") {
      context("stream") {
        it("no space between params") {
          self.match(Pro.getOutput(), "A\n---\nB|trim=true\n~~~") {
            expect($0.isStream).to(beTrue())
            expect($1).to(beEmpty())
          }
        }

        it("has title") {
          self.match(Pro.getOutput(), "A Title\n~~~") {
            expect($0.isStream).to(beTrue())
            expect($0.title.getValue()).to(equal("A Title"))
            expect($1).to(beEmpty())
          }
        }
      }

      context("no stream") {
        it("handles base case") {
          self.match(Pro.getOutput(), "") {
            expect($0.isStream).to(beFalse())
            expect($1).to(beEmpty())
          }
        }

        it("has title") {
          self.match(Pro.getOutput(), "A Title\n") {
            expect($0.isStream).to(beFalse())
            expect($0.title.getValue()).to(equal("A Title"))
            expect($1).to(beEmpty())
          }

          self.match(Pro.getOutput(), "A Title") {
            expect($0.isStream).to(beFalse())
            expect($0.title.getValue()).to(equal("A Title"))
            expect($1).to(beEmpty())
          }
        }
      }
    }
  }
}
