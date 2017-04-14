import Quick
import Nimble
@testable import BitBar

private let examplePlugin = App.path(forResource: "sub.2m.sh")

class BashTests: Helper {
  override func spec() {
    context("base case") {
      // it("handles base case") {
      //   let menu = Menu("hello")
      //   let bash = Bash(examplePlugin)
      //   menu.add(params: [Refresh(true)])
      //   bash.applyTo(menu: menu)
      //   var this = 0
      //   menu.onDidRefresh {
      //     this = 1
      //   }
      //   menu.trigger()
      //   expect(this).toEventually(equal(1), timeout: 10)
      // }
    }

    context("parser") {
      it("handles base case without quotes") {
        let bash = "/a/b/c.sh"
        self.match(Pro.getBash(), "bash=" + bash) {
          expect($0.getValue()).to(equal(bash))
        }
      }

      context("quotes") {
        it("handles double quotes") {
          let bash = "\"A B C\""
          self.match(Pro.getBash(), "bash=" + bash) {
            expect($0.getValue()).to(equal("A B C"))
          }
        }

        it("handles single quotes") {
          let bash = "'A B C'"
          self.match(Pro.getBash(), "bash=" + bash) {
            expect($0.getValue()).to(equal("A B C"))
          }
        }

        it("handles double quotes with no content") {
          let bash = "\"\""
          self.match(Pro.getBash(), "bash=" + bash) {
            expect($0.getValue()).to(equal(""))
          }
        }

        it("handles double quotes with no content") {
          let bash = "''"
          self.match(Pro.getBash(), "bash=" + bash) {
            expect($0.getValue()).to(equal(""))
          }
        }
      }

      it("handles base case with quotes") {
        let bash = "\"/a/b/c.sh\""
        self.match(Pro.getBash(), "bash=" + bash) {
          expect($0.getValue()).to(equal("/a/b/c.sh"))
        }
      }
    }

    context("clickable") {
      let setup = { (_ input: String..., block: @escaping (Menuable) -> Void) in
        self.match(Pro.menu, input.joined() + "\n") { (menu, _) in
          block(menu)
        }
      }

      it("is clickable when terminal=true") {
        setup("A | terminal=true bash='/a/b/c'") { menu in
          expect(the(menu)).to(beClickable())
        }
      }

      it("is clickable when terminal=false") {
        setup("A | terminal=false bash='/a/b/c'") { menu in
          expect(the(menu)).to(beClickable())
        }
      }

      it("is not clickable only using terminal=false") {
        setup("A | terminal=false") { menu in
          expect(the(menu)).toNot(beClickable())
        }
      }

      it("is not clickable only using terminal=true") {
        setup("A | terminal=true") { menu in
          expect(the(menu)).toNot(beClickable())
        }
      }
    }
  }
}
