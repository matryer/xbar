import Quick
import Nimble
@testable import BitBar

class ParserTests: Helper {
  override func spec() {
    it("should parse quotes") {
      self.match(Pro.quote(), "\"A\"") {
        expect($0).to(equal("A"))
      }
    }

    // it("should parse escaped chars") {
    //   self.match(Pro.quote(), "\"A\\\"\"") {
    //     expect($0).to(equal("A\\"))
    //   }
    // }
  }
}
