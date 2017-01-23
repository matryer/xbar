import Quick
import Nimble
@testable import BitBar

class MenuTests: Helper {
  override func spec() {
    App.startedTesting()
    describe("menu") {
      let addPrefix = { "\n---\n" + $0 }
      context("params") {
        it("handles params") {
          self.match(Pro.getMenu(), addPrefix("My Menu|")) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(equal(""))
          }
        }
      }

      context("sub menu") {
        it("has one sub") {
          self.match(Pro.getMenu(), addPrefix("My Menu\n--A")) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($0.menus).to(haveCount(1))
            expect($0.menus[0].getValue()).to(equal("A"))
            expect($1).to(beEmpty())
          }
        }

        it("has +1 subs") {
          self.match(Pro.getMenu(), addPrefix("My Menu\n--A\n--B")) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($0.menus).to(haveCount(2))
            expect($0.menus[0].getValue()).to(equal("A"))
            expect($0.menus[1].getValue()).to(equal("B"))
            expect($1).to(beEmpty())
          }
        }

        it("has menu with params and +1 subs") {
          self.match(Pro.getMenu(), addPrefix("My Menu| size=10\n--A\n--B")) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($0.menus).to(haveCount(2))
            expect($0.menus[0].getValue()).to(equal("A"))
            expect($0.menus[1].getValue()).to(equal("B"))
            expect($1).to(beEmpty())
          }
        }

        it("has subs with params") {
          self.match(Pro.getMenu(), addPrefix("My Menu\n--A| font=X \n--B")) {
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
          self.match(Pro.getMenu(), addPrefix("My Menu")) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(beEmpty())
          }
        }

        it("handles no input") {
          self.match(Pro.getMenu(), addPrefix("")) {
            expect($0.getValue()).to(equal(""))
            expect($1).to(beEmpty())
          }
        }
      }

      context("params") {
        it("consumes spaces") {
          let arg = addPrefix("My Menu| terminal=true ")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(beEmpty())
          }
        }

        it("handles stream") {
          let arg = addPrefix("My Menu| terminal=true")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu"))
          }
        }

        context("terminal") {
          it("it handles true") {
            let arg = addPrefix("My Menu|terminal=true")
            self.match(Pro.getMenu(), arg) {
              expect($0.getValue()).to(equal("My Menu"))
              expect($1).to(beEmpty())
            }
          }

          it("it handles false") {
            let arg = addPrefix("My Menu|terminal=false")
            self.match(Pro.getMenu(), arg) {
              expect($0.getValue()).to(equal("My Menu"))
              expect($1).to(beEmpty())
            }
          }

          it("it handles space between menu and param") {
            let arg = addPrefix("My Menu | terminal=false")
            self.match(Pro.getMenu(), arg) {
              expect($0.getValue()).to(equal("My Menu"))
              expect($1).to(beEmpty())
            }
          }
        }

        context("trim") {
          it("it handles true") {
            let arg = addPrefix("My Menu|terminal=true trim=true")
            self.match(Pro.getMenu(), arg) {
              expect($0.getValue()).to(equal("My Menu"))
              expect($1).to(beEmpty())
            }
          }

          it("it handles false") {
            let arg = addPrefix("My Menu |terminal=false trim=false")
            self.match(Pro.getMenu(), arg) {
              expect($0.getValue()).to(equal("My Menu "))
              expect($1).to(beEmpty())
            }
          }

          it("it handles space between menu and param") {
            let arg = addPrefix("My Menu | terminal=false trim=false")
            self.match(Pro.getMenu(), arg) {
              expect($0.getValue()).to(equal("My Menu "))
              expect($1).to(beEmpty())
            }
          }
        }
      }
    }
  }
}
