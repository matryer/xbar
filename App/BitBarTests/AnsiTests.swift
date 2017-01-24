import Quick
import Nimble
@testable import BitBar

class AnsiTests: QuickSpec {
  override func spec() {
    describe("ansi") {
      it("handles base case") {
        let input = "ABC\\e[3;4;33mDEF\\e[0mGHI"
        switch Pro.parse(Pro.getANSIs(), input) {
        case let Result.success(result, rem):
          expect(result[0] as? String).to(equal("ABC"))
          expect(result[1] as? [Int]).to(equal([3, 4, 33]))
          expect(result[2] as? String).to(equal("DEF"))
          expect(result[3] as? [Int]).to(equal([0]))
          expect(result[4] as? String).to(equal("GHI"))
          expect(rem).to(beEmpty())
        case let Result.failure(error):
          fail("Got error: \(error)")
        }
      }

      it("handles nested") {
        let input = "\033[34mA\033[32mN\033[31mS\033[33mI\033[0m"
        switch Pro.parse(Pro.getANSIs(), input) {
        case let Result.success(result, rem):
          expect(result[0] as? [Int]).to(equal([34]))
          expect(result[1] as? String).to(equal("A"))
          expect(result[2] as? [Int]).to(equal([32]))
          expect(result[3] as? String).to(equal("N"))
          expect(result[4] as? [Int]).to(equal([31]))
          expect(result[5] as? String).to(equal("S"))
          expect(result[6] as? [Int]).to(equal([33]))
          expect(result[7] as? String).to(equal("I"))
          expect(result[8] as? [Int]).to(equal([0]))
          expect(rem).to(beEmpty())
        case let Result.failure(error):
          fail("Got error: \(error)")
        }
      }
    }
  }
}
