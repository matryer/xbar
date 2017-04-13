import Quick
import Nimble
@testable import BitBar

// TODO: Replace getInput with input
// TODO: Move to class
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
    return path
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
    return data
  }
}

extension Href {
  func getValue() -> String {
    return raw
  }
}

func verifyUrl(url: String) {
  let image = Image(url)
  let menu = Menu.arbitrary.sample[0]
  image.menu(didLoad: menu)
  expect(menu.image).toEventuallyNot(beNil())
}

func verifyInvalidUrl(url: String) {
  let image = Image(url)
  let menu = Menu.arbitrary.sample[0]
  image.menu(didLoad: menu)
  expect(menu.image).toEventually(beNil(), timeout: 5)
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

    describe("url") {
      context("exist") {
        it("handles valid image url") {
          verifyUrl(url: "https://i.imgur.com/WVeH43e.png")
        }

        it("handles invalid image url") {
          verifyInvalidUrl(url: "https://google.com")
        }
      }

      context("does not exist") {
        it("handles non existent url") {
          verifyInvalidUrl(url: "https://i.imgur.com/WVeH43e.xxx")
        }
      }
    }
  }
}
