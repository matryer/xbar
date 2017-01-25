import Quick
import Nimble
@testable import BitBar

private let examplePlugin = App.path(forResource: "sub.10s.sh")

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
  }
}
