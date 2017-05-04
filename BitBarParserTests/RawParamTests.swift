import Quick
import Nimble
import SwiftCheck
@testable import BitBarParser

class RawParamTests: QuickSpec {
  override func spec() {
    it("handles raw params") {
      property("raw param") <- forAll { (param: Raw.Param) in
        switch Pro.parse(Pro.param, param.output) {
        case let .success(output):
          return param ==== output
        case let .failure(error):
          return false <?> String(describing: error)
        }
      }
    }
  }
}
