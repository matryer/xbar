import Quick
import Nimble
@testable import BitBar

// public func beASuccess(with exp: String? = nil) -> MatcherFunc<Script.Result> {
//   return MatcherFunc { actualExpression, failureMessage in
//     failureMessage.postfixMessage = "exit with status 0 and output '\(exp)'"
//     guard let result = try actualExpression.evaluate() else {
//       return false
//     }

//     switch (result, exp) {
//     case (.success(_, 0), .none):
//       return true
//     case let (.success(stdout, 0), .some(exp)) where stdout == exp:
//       return true
//     default:
//       failureMessage.postfixActual = String(describing: result)
//       return false
//     }
//   }
// }

extension Image {
  func getValue() -> String {
    return raw
  }
}

extension Size {
  func getValue() -> Int {
    return Int(float)
  }
}

extension Length {
  func getValue() -> Int {
    return length
  }
}

extension NamedParam {
  func getValue() -> String {
    return value
  }
}

extension Terminal {
  func getValue() -> Bool {
    return bool
  }
}

extension Bash {
  func getValue() -> String {
    return value
  }
}

extension Ansi {
  func getValue() -> Bool {
    return active
  }
}

extension Color {
  func getValue() -> String {
    return raw
  }
}

extension Dropdown {
  func getValue() -> Bool {
    return bool
  }
}

extension Font {
  func getValue() -> String {
    return name
  }
}

extension Trim {
  func getValue() -> String {
    return String(value)
  }
}

extension TemplateImage {
  func getValue() -> String {
    return value
  }
}

extension Href {
  func getValue() -> String {
    return raw
  }
}

class ImageTests: Helper {
  func verifyBase64(_ parser: P<Image>, _ name: String) {
    describe(name) {
      it("handles valid string") {
        self.match(parser, name + "=dGVzdGluZw==") {
          expect($0.getValue()).to(equal("dGVzdGluZw=="))
          expect($1).to(equal(""))
        }
      }

      context("whitespace") {
        let image = "dGVzdGluZw=="
        it("strips pre whitespace") {
          self.match(parser, name + "=    " + image) {
            expect($0.getValue()).to(equal(image))
            expect($1).to(equal(""))
          }
        }

        it("strips post whitespace") {
          self.match(parser, name + "=" + image + "  ") {
            expect($0.getValue()).to(equal(image))
            expect($1).to(equal(""))
          }
        }

        it("strips whitespace") {
          self.match(parser, name + "=  " + image + "  ") {
            expect($0.getValue()).to(equal(image))
            expect($1).to(equal(""))
          }
        }
      }

      context("fails") {
        it("fails on empty string") {
          self.failure(parser, name + "=")
        }
      }
    }
  }

  override func spec() {
    describe("parser") {
      describe("image") {
        verifyBase64(Pro.getImage(), "image")
      }

      describe("templateImage") {
        verifyBase64(Pro.getTemplateImage(), "templateImage")
      }
    }
  }
}
