import Quick
import Nimble
@testable import BitBar

class EmojizeTests: Helper {
  override func spec() {
    let check = { (_ input: String, block: @escaping (String) -> Void) in
      self.test(Emojize.parser, input, block)
    }

    it("doesn't alter regular strings") {
      check("Hello") {
        expect($0).to(equal("Hello"))
      }
    }

    it("handles empty strings") {
      check("") {
        expect($0).to(equal(""))
      }
    }

    it("replaces single unicode chars") {
      check(":mushroom:") {
        expect($0).to(equal("🍄"))
      }
    }

    it("replaces multiply unicode chars") {
      check(":mushroom: :car:") {
        expect($0).to(equal("🍄 🚗"))
      }
    }

    it("ignores chars it cannot find") {
      check(":--not-found--:") {
        expect($0).to(equal(":--not-found--:"))
      }
    }

    it("replaces unicode chars surrounded by text") {
      check("This is my :car:, it's fast") {
        expect($0).to(equal("This is my 🚗, it's fast"))
      }
    }

    it("handles found with non found") {
      check("ABC :car: DEF :not-found:") {
        expect($0).to(equal("ABC 🚗 DEF :not-found:"))
      }
    }

    it("handles non closed tags") {
      check("ABC :car: DEF : XYZ") {
        expect($0).to(equal("ABC 🚗 DEF : XYZ"))
      }
    }
  }
}
