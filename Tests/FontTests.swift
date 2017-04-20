import Quick
import Nimble
import Attr
@testable import BitBar

class FontTests: Helper {
  override func spec() {
    describe("parser") {
      let aFont = "Times New Roman"
      let parser = Pro.getFont()

      context("non existing fonts") {
        it("fails if the font doesn't exist") {
          self.failure(Pro.getFont(), "font=XYZ")
        }

        it("fails on empty font") {
          self.failure(Pro.getFont(), "font=")
        }

        it("fails on empty with quotes") {
          self.failure(Pro.getFont(), "font=\"\"")
        }

        it("fails on blank with quotes") {
          self.failure(Pro.getFont(), "font=\"      \"")
        }

        it("fails on blank font") {
          self.failure(Pro.getFont(), "font=     ")
        }
      }

      it("handles base case") {
        expect(input("font=Monaco", with: parser)).to(output("Monaco"))
      }

      it("handles double quotes") {
        expect(input("font=\"\(aFont)\"", with: parser)).to(output(aFont))
      }

      it("handles lowercased font") {
        expect(input("font=monaco", with: parser)).to(output("monaco"))
      }

      it("handles single quotes") {
        expect(input("font='\(aFont)'", with: parser)).to(output(aFont))
      }
    }
  }
}
