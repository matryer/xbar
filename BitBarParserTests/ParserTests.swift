import Quick
import Nimble
import SwiftCheck
@testable import BitBarParser

class ParserTests: QuickSpec {
  override func spec() {
    context("until") {
      it("should match until, but not include") {
        switch Pro.parse(Pro.until(["X"]), "ABC DEFX") {
        case let .success(output):
          expect(output).to(equal("ABC DEF"))
        case let .failure(error):
          fail(String(describing: error))
        }
      }

      it("should match first one") {
        switch Pro.parse(Pro.add(Pro.until(["B", "A"]), Pro.s("B")), "RAB") {
        case let .success(output):
          expect(output).to(equal("R"))
        case let .failure(error):
          fail(String(describing: error))
        }
      }

      it("should handle \\") {
        switch Pro.parse(Pro.add(Pro.until(["B", "A"]), Pro.s("AB")), "R\\\\AAB") {
        case let .success(output):
          expect(output).to(equal("R\\"))
        case let .failure(error):
          fail(String(describing: error))
       }
     }

      it("it ignores escaped") {
        switch Pro.parse(Pro.add(Pro.until(["B", "A"]), Pro.s("B")), "R\\AAB") {
        case let .success(output):
          expect(output).to(equal("RA"))
        case let .failure(error):
          fail(String(describing: error))
        }
      }

      it("it ignores escaped 3") {
        switch Pro.parse(Pro.add(Pro.until(["B", "A"]), Pro.s("B")), "\\RAB") {
        case let .success(output):
          expect(output).to(equal("\\R"))
        case let .failure(error):
          fail(String(describing: error))
        }
      }

      it("handles sub strings") {
        switch Pro.parse(Pro.add(Pro.until(["BBB", "B"]), Pro.s("A")), "ZBA") {
        case let .success(output):
          expect(output).to(equal("Z"))
        case let .failure(error):
          fail(String(describing: error))
        }
      }

      it("handles empty match") {
        switch Pro.parse(Pro.add(Pro.until(["A", "B"]), Pro.s("C")), "BC") {
        case let .success(output):
          expect(output).to(equal(""))
        case let .failure(error):
          fail(String(describing: error))
        }
      }

      it("it ignores escaped 2") {
        switch Pro.parse(Pro.add(Pro.until(["B", "A"]), Pro.s("B\\")), "R\\AAB\\") {
        case let .success(output):
          expect(output).to(equal("RA"))
        case let .failure(error):
          fail(String(describing: error))
        }
      }

      it("no consume") {
        switch Pro.parse(Pro.add(Pro.until(["B", "A"], consume: false), Pro.s("AB")), "RAB") {
        case let .success(output):
          expect(output).to(equal("R"))
        case let .failure(error):
          fail(String(describing: error))
        }
      }
    }
  }
}
