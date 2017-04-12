import Quick
import Nimble
@testable import BitBar

class FontTests: Helper {
  override func spec() {
    let aFont = "Times New Roman"
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
      self.match(Pro.getFont(), "font=Monaco") {
        expect($0.getValue()).to(equal("Monaco"))
      }
    }

    it("handles double quotes") {
      self.match(Pro.getFont(), "font=" + "\"\(aFont)\"") {
        expect($0.getValue()).to(equal(aFont))
      }
    }

    it("handles lowercased font") {
      self.match(Pro.getFont(), "font=monaco") {
        expect($0.getValue()).to(equal("Monaco"))
      }
    }

    it("handles single quotes") {
      let font = "'\(aFont)'"
      self.match(Pro.getFont(), "font=" + font) {
        expect($0.getValue()).to(equal(aFont))
      }
    }
  }
}
