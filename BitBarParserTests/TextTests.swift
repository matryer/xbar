import Quick
import Nimble
import SwiftCheck
@testable import BitBarParser

class TextTests: QuickSpec {
  override func spec() {
    it("tests text") {
      property("text") <- forAll(Text.arbitrary) { text in
        switch Pro.parse(Pro.output, text.output + "\n") {
        case let .success(head):
          return text ==== head
        case let .failure(error):
          return false <?> String(describing: error)
        }
      }
    }
  }
}
