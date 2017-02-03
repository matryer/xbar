import Quick
import Nimble
@testable import BitBar

class MenuTests: Helper {
  override func spec() {
    let addSuffix = { return $0 + "\n" }
    context("params") {
      it("fails on | but no params") {
        self.failure(Pro.menu, addSuffix("My Menu|"))
      }
    }

    it("handles no input") {
      self.match(Pro.getMenu(), addSuffix("")) {
        expect($0.getValue()).to(equal(""))
        expect($0.menus).to(haveCount(0))
        expect($1).to(beEmpty())
      }
    }

    it("handles escaped input") {
      self.match(Pro.getMenu(), addSuffix("A B C\\|")) {
        expect($0.getValue()).to(equal("A B C|"))
        expect($0.menus).to(haveCount(0))
        expect($1).to(beEmpty())
      }
    }

    context("sub menu") {
      it("has one sub") {
        self.match(Pro.getMenu(), addSuffix("My Menu\n--A")) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($0.menus).to(haveCount(1))
          expect($0.menus[0].getValue()).to(equal("A"))
          expect($1).to(beEmpty())
        }
      }

      it("has +1 subs") {
        self.match(Pro.getMenu(), addSuffix("My Menu\n--A\n--B")) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($0.menus).to(haveCount(2))
          expect($0.menus[0].getValue()).to(equal("A"))
          expect($0.menus[1].getValue()).to(equal("B"))
          expect($1).to(beEmpty())
        }
      }

      it("has menu with params and +1 subs") {
        self.match(Pro.getMenu(), addSuffix("My Menu| size=10\n--A\n--B")) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($0.menus).to(haveCount(2))
          expect($0.menus[0].getValue()).to(equal("A"))
          expect($0.menus[1].getValue()).to(equal("B"))
          expect($1).to(beEmpty())
        }
      }

      it("has subs with params") {
        self.match(Pro.getMenu(), addSuffix("My Menu\n--A| font=X \n--B")) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($0.menus).to(haveCount(2))
          let sub = $0.menus[0]
          expect(sub.getValue()).to(equal("A"))
          expect($0.menus[1].getValue()).to(equal("B"))
          expect($1).to(beEmpty())
        }
      }
    }

    context("no sub menu") {
      it("handles base case") {
        self.match(Pro.getMenu(), addSuffix("My Menu")) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($1).to(beEmpty())
        }
      }

      it("handles no input") {
        self.match(Pro.getMenu(), addSuffix("")) {
          expect($0.getValue()).to(equal(""))
          expect($1).to(beEmpty())
        }
      }
    }

    context("params") {
      it("consumes spaces") {
        let arg = addSuffix("My Menu| terminal=true ")
        self.match(Pro.getMenu(), arg) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($1).to(beEmpty())
        }
      }

      it("handles stream") {
        let arg = addSuffix("My Menu| terminal=true")
        self.match(Pro.getMenu(), arg) {
          expect($0.getValue()).to(equal("My Menu"))
        }
      }

      context("terminal") {
        it("it handles true") {
          let arg = addSuffix("My Menu|terminal=true")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(beEmpty())
          }
        }

        it("it handles false") {
          let arg = addSuffix("My Menu|terminal=false")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(beEmpty())
          }
        }

        it("it handles space between menu and param") {
          let arg = addSuffix("My Menu | terminal=false")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(beEmpty())
          }
        }
      }

      context("trim") {
        it("it handles true") {
          let arg = addSuffix("My Menu|terminal=true trim=true")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(beEmpty())
          }
        }

        it("it handles false") {
          let arg = addSuffix("My Menu |terminal=false trim=false")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu "))
            expect($1).to(beEmpty())
          }
        }

        it("it handles space between menu and param") {
          let arg = addSuffix("My Menu | terminal=false trim=false")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu "))
            expect($1).to(beEmpty())
          }
        }
      }
    }

    context("merge") {
      it("merges title") {
        let menu1 = Menu("X")
        let menu2 = Menu("Y")

        expect(menu1.equals(menu2)).to(beFalse())
        menu1.merge(with: menu2)
        expect(menu1.equals(menu2)).to(beTrue())
        expect(menu2.equals(menu2)).to(beTrue())
      }

      it("merges sub menus") {
        let menu1 = Menu("M1")
        let menu2 = Menu("M2")
        let title1 = Menu("T1", menus: [menu1])
        let title2 = Menu("T2", menus: [menu2])

        title1.merge(with: title2)

        expect(title1.menus).to(haveCount(1))
        expect(title2.menus).to(haveCount(1))

        expect(title1.menus[0].equals(title2.menus[0])).to(beTrue())
      }
    }
  }
}
