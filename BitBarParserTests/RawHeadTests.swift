import Quick
import Nimble
import SwiftCheck
@testable import BitBarParser

class RawHeadTests: QuickSpec {
  override func spec() {
    it("handles raw head") {
      property("raw head") <- forAll { (head: Raw.Head) in
        switch Pro.parse(Pro.output, head.output + "\n") {
          case let .success(output):
            return head ==== output
          case let .failure(error):
            return false <?> String(describing: error)
         }
       }
     }

      fit("handles generate") {
        property("raw head") <- forAll { (head: Raw.Head) in
          return head ==== head.reduce()
       }
     }
  }
}
