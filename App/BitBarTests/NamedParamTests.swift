import Quick
import Nimble
@testable import BitBar

class NamedParamTests: Helper {
  override func spec() {
    App.startedTesting()

    it("handles base case") {
      self.match(Pro.getParam(), "param1=a-value") {
        expect($0.getValue()).to(equal("a-value"))
        expect($1).to(equal(""))
      }
    }

    it("must start with a number") {
      self.failure(Pro.getParam(), "paramX=a-value")
    }
  }
}
