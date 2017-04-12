import Quick
import Nimble
@testable import BitBar

class HrefTests: Helper {
  override func spec() {
    describe("href") {
      it("handles base case") {
        self.match(Pro.getHref(), "href=http://google.com") {
          expect($0.getValue()).to(equal("http://google.com"))
        }
      }

      it("handles double quotes") {
        let href = "\"http://google.com\""
        self.match(Pro.getHref(), "href=" + href) {
          expect($0.getValue()).to(equal("http://google.com"))
        }
      }

      it("should be able to contain single quotes if double are used") {
        let href = "\"http://google'''\""
        self.match(Pro.getHref(), "href=" + href) {
          expect($0.getValue()).to(equal("http://google'''"))
        }
      }

      it("should be able to contain double quotes if single are used") {
        let href = "'http://google\"\"\"'"
        self.match(Pro.getHref(), "href=" + href) {
          expect($0.getValue()).to(equal("http://google\"\"\""))
        }
      }

      it("handles single quotes") {
        let href = "'http://google.com'"
        self.match(Pro.getHref(), "href=" + href) {
          expect($0.getValue()).to(equal("http://google.com"))
        }
      }

      it("handles double quotes with no content") {
        let href = "\"\""
        self.match(Pro.getHref(), "href=" + href) {
          expect($0.getValue()).to(equal(""))
        }
      }

      it("handles double quotes with no content") {
        let href = "''"
        self.match(Pro.getHref(), "href=" + href) {
          expect($0.getValue()).to(equal(""))
        }
      }
    }
  }
}
