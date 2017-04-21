import Quick
import Nimble
@testable import BitBar

class NamedParamTests: Helper {
  override func spec() {
    context("parser") {
      let parser = Pro.getParam()

      it("handles base case") {
        expect(input("param1=a-value", with: parser)).to(output("a-value"))
      }

      it("must start with a number") {
        self.failure(parser, "paramX=a-value")
      }
    }
  }
}
