import Quick
import Nimble
@testable import BitBar

class FontTests: Helper {
  override func spec() {
    it("handles base case") {
      self.match(Pro.getFont(), "font=UbuntuMono-Bold") {
        expect($0.getValue()).to(equal("UbuntuMono-Bold"))
      }
    }

    it("handles double quotes") {
      let font = "\"A B C\""
      self.match(Pro.getFont(), "font=" + font) {
        expect($0.getValue()).to(equal("A B C"))
      }
    }

    it("handles single quotes") {
      let font = "'A B C'"
      self.match(Pro.getFont(), "font=" + font) {
        expect($0.getValue()).to(equal("A B C"))
      }
    }

    it("handles double quotes with no content") {
      let font = "\"\""
      self.match(Pro.getFont(), "font=" + font) {
        expect($0.getValue()).to(equal(""))
      }
    }

    it("handles double quotes with no content") {
      let font = "''"
      self.match(Pro.getFont(), "font=" + font) {
        expect($0.getValue()).to(equal(""))
      }
    }
  }
}
