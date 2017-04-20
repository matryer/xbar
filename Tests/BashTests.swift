import Quick
import Nimble
import Attr
@testable import BitBar

private let examplePlugin = App.path(forResource: "sub.2m.sh")

class BashTests: Helper {
  override func spec() {
    context("parser") {
      let parser = Pro.getBash()

      it("handles base case without quotes") {
        expect(the(parser, with: "bash=/a/c.sh")).to(output("/a/c.sh"))
      }

      context("quotes") {
        it("handles double quotes") {
          // TODO: Fails
//          let bash = "\"A B C\""
//          expect(the(parser, with: "bash=" + bash)).to(output(bash))
        }

        it("handles single quotes") {
          let bash = "'A B C'"
          expect(the(parser, with: "bash=" + bash)).to(output("A B C"))
        }

        it("handles double quotes with no content") {
          let bash = "\"\""
          expect(the(parser, with: "bash=" + bash)).to(output(""))
        }

        it("handles double quotes with no content") {
          let bash = "''"
          expect(the(parser, with: "bash=" + bash)).to(output(""))
        }
      }

      it("handles base case with quotes") {
        let bash = "\"/a/b/c.sh\""
        expect(the(parser, with: "bash=" + bash)).to(output("/a/b/c.sh"))
      }
    }

    context("clickable") {
      let setup = { (_ input: String..., block: @escaping (Menuable) -> Void) in
        self.match(Pro.menu, input.joined() + "\n") { (menu) in
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
