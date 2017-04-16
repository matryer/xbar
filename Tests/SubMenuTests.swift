import Quick
import Nimble
@testable import BitBar

class SubMenuTests: Helper {
  override func spec() {
    describe("sub menu") {
      context("only submenu") {
        it("handles base case") {
          self.match(Pro.getSubMenu(), "--My Sub Menu\n") {
            expect($0.getValue()).to(equal("My Sub Menu"))
          }
        }

        it("handles only new line") {
          self.match(Pro.getSubMenu(), "--\n") {
            expect($0.getValue()).to(equal(""))
          }
        }

        it("handles just --") {
          self.match(Pro.getSubMenu(), "--\n") {
            expect($0.getValue()).to(equal(""))
          }
        }
      }

      context("sub menus") {
        let addPrefix = { "--" + $0 }
        it("has one sub") {
          self.match(Pro.getSubMenu(), addPrefix("Sub\n----A\n")) {
            expect($0.getValue()).to(equal("Sub"))
            expect($0.menus).to(haveCount(1))
            expect($0.menus[0].getValue()).to(equal("A"))
            expect($1).to(beEmpty())
          }
        }

        it("has +1 subs") {
          self.match(Pro.getSubMenu(), addPrefix("Sub\n----A\n----B\n")) {
            expect($0.getValue()).to(equal("Sub"))
            expect($0.menus).to(haveCount(2))
            expect($0.menus[0].getValue()).to(equal("A"))
            expect($0.menus[1].getValue()).to(equal("B"))
            expect($1).to(beEmpty())
          }
        }

        it("has menu with params and +1 subs") {
          self.match(Pro.getSubMenu(), addPrefix("Sub\n----A | size=2 \n----B\n")) {
            expect($0.getValue()).to(equal("Sub"))
            expect($0.menus).to(haveCount(2))
            let sub = $0.menus[0]
            expect(sub.getValue()).to(equal("A"))
            expect($0.menus[1].getValue()).to(equal("B"))
            expect($1).to(beEmpty())
          }
        }

        it("has menu with no content") {
          self.match(Pro.getSubMenu(), addPrefix("Sub\n----\n")) {
            expect($0.getValue()).to(equal("Sub"))
            expect($0.menus).to(haveCount(1))
            let sub = $0.menus[0]
            expect(sub.getValue()).to(equal(""))
            expect($1).to(beEmpty())
          }
        }

        it("handles nested menus") {
          self.match(Pro.getSubMenu(), addPrefix("Sub\n----A\n------B\n----C\n")) {
            expect($0.getValue()).to(equal("Sub"))
            expect($0.menus).to(haveCount(2))
            let sub = $0.menus[0]
            expect(sub.menus).to(haveCount(1))
            expect(sub.getValue()).to(equal("A"))
            let sub2 = sub.menus[0]
            expect(sub2.getValue()).to(equal("B"))
            expect($0.menus[1].getValue()).to(equal("C"))
            expect($1).to(beEmpty())
          }
        }
      }
    }
  }
}
