import Quick
import Nimble
@testable import BitBar

class TitleTests: Helper {
  override func spec() {
    App.startedTesting()

    describe("title") {
      it("menu") {
        let input = "S0 YM 2DR \n---\nL\n--i\n---\nC"
        self.match(Pro.getTitle(), input) {
          expect($0.getValue()).to(equal("S0 YM 2DR"))
          expect($0.menus).to(haveCount(2))
          expect($1).to(beEmpty())
        }
      }

      it("no longer failes") {
        let input = "A\n---\nB\n---\nD"

        self.match(Pro.getTitle(), input) {
          expect($0.getValue()).to(equal("A"))
          expect($0.menus[0].getValue()).to(equal("B"))
          expect($0.menus).to(haveCount(2))
          expect($1).to(beEmpty())
        }
      }

      context("no menu") {
        it("handles base case") {
          self.match(Pro.getTitle(), "My Title") {
            expect($0.getValue()).to(equal("My Title"))
            expect($1).to(beEmpty())
          }
        }

        it("handles no input") {
          self.match(Pro.getTitle(), "") {
            expect($0.getValue()).to(beEmpty())
            expect($1).to(beEmpty())
          }
        }
      }

      context("with menu") {
        it("handles base case") {
          self.match(Pro.getTitle(), "My Title\n---\n") { (title: Title, rem: String) in
            expect(title.getValue()).to(equal("My Title"))
            expect(title.menus).to(haveCount(1))
            expect(title.menus[0].getValue()).to(equal(""))
            expect(rem).to(beEmpty())
          }
        }

        it("handles nested menus") {
          let arg = "My Title\n---\nA\n--B\n----C"
          self.match(Pro.getTitle(), arg) { (title: Title, _) in
            expect(title.getValue()).to(equal("My Title"))
            expect(title.menus).to(haveCount(1))
            expect(title.menus[0].getValue()).to(equal("A"))
            expect(title.menus[0].menus[0].getValue()).to(equal("B"))
            expect(title.menus[0].menus[0].menus[0].getValue()).to(equal("C"))
          }
        }
      }
    }
  }
}
