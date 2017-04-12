import Quick

import Nimble
@testable import BitBar

class OutputTests: Helper {
  override func spec() {
    context("stream") {
      it("no space between params") {
        self.match(Pro.getOutput(), "A\n---\nB|trim=true\n~~~\n") {
          expect($0.title.getTitle()).to(equal("A"))
          expect($0.title.menus).to(haveCount(1))
          expect($0.title.menus[0].getTitle()).to(equal("B"))
          expect($0.title.menus[0].openTerminal()).to(beTrue())
          expect($1).to(beEmpty())
        }
      }

      it("has title") {
        self.match(Pro.getOutput(), "A Title\n~~~\n") {
          expect($0.isStream).to(beTrue())
          expect($0.title.getValue()).to(equal("A Title"))
          expect($1).to(beEmpty())
        }
      }
    }

    context("no stream") {
      it("handles base case") {
        self.match(Pro.getOutput(), "\n") {
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
      }
    }
  }
}
