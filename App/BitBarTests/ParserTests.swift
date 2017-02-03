import Quick
import Nimble
@testable import BitBar

// let quote: String = "\""

func toQuote(_ value: String, quote: String) -> String {
  return quote + escape(value, quote) + quote
}

func escape(_ what: String, _ toEscape: String) -> String {
  return what.replace(toEscape, "\\" + toEscape)
}

func unescape(_ what: String, _ toEscape: String) -> String {
  return what.replace("\\" + toEscape, toEscape)
}

let quotes =  ["\"", "'"]
class ParserTests: Helper {
  override func spec() {
    let testQuote = { (input: String, quote: String) in
      let escaped = toQuote(input, quote: quote)
      self.match(Pro.quote(), escaped) {
        expect($0).to(equal(input))
      }
    }

    let testFail = { (input: String) in
      self.failure(Pro.quote(), input)
    }

    for quote in quotes {
      describe("quotes \(quote)") {
        it("should parse quotes") {
          testQuote("ABC", quote)
        }

        it("should parse escaped chars") {
          testQuote("ABC" + quote + quote + quote, quote)
        }

        it("handles empty") {
          testQuote("", quote)
        }

        it("handles quote within") {
          testQuote("A" + quote  + "B", quote)
        }

        it("handles no quotes and space") {
          testQuote("A B C", quote)
        }

        it("handles quotes and space") {
          testQuote(quote + "A B C" + quote, quote)
        }

        it("handles only quote") {
          testQuote(quote, quote)
        }
      }
    }

    context("combine") {
      for quote1 in quotes {
        for quote2 in quotes {
          it("handles both \(quote1) and \(quote2) at the same time") {
            testQuote(quote1 + "A" + quote2 + "B" + quote1 + "C" + quote2, quote1)
            testQuote(quote1 + "A" + quote2 + "B" + quote1 + "C" + quote2, quote2)
          }
        }
      }
    }

    context("fails") {
      it("fails if no matching quote is found") {
        testFail("\"ABC")
      }

      it("fails on plain string") {
        testFail("ABC")
      }

      it("fails on uneven, unequal quotes") {
        testFail("\"X'")
      }

      it("fails on uneven amount of quotes") {
        testFail("\"\"\"")
      }
    }

    describe("the escape func for titles") {
      it("should escape empty string") {
        expect(escape(title: "", what: [])).to(equal(""))
      }

      context("empty list") {
        it("should ignore char") {
          expect(escape(title: "X", what: [])).to(equal("X"))
        }
      }

      context("within list") {
        it("should not ignore char") {
          expect(escape(title: "X", what: ["X"])).to(equal("\\X"))
        }

        it("should only escape value that's within the list") {
          expect(escape(title: "X Y", what: ["X"])).to(equal("\\X Y"))
        }

        it("should always escape backslash") {
          expect(escape(title: "X \(slash) Y", what: [String]())).to(equal("X \(slash + slash) Y"))
        }

        context("quotes") {
          let single = "\'"
          let double = "\""
          it("handle single quotes") {
            expect(escape(title: "A" + single, what: [single]))
              .to(equal("A" + slash + single))
          }

          it("handle double quotes") {
            expect(escape(title: "A" + double, what: [double]))
              .to(equal("A" + slash + double))
          }
        }
      }

      context("title") {
        it("should escape slash") {
          expect(escape(title: "A" + slash)).to(equal("A" + slash + slash))
        }

        it("should escape pipe") {
          expect(escape(title: "A | B")).to(equal("A " + slash + "|" + " B"))
        }

        it("should handle empty strings") {
          expect(escape(title: "")).to(beEmpty())
        }

        it("should not care about space") {
          let input = "     "
          expect(escape(title: input)).to(equal(input))
        }
      }


      // it("should escape a single char") {
      //   expect(escape(title: "A", what: "A")).to(equal("\\A"))
      // }
    }
  }
}
