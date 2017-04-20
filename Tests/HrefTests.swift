import Quick
import Nimble
import Attr
@testable import BitBar

class HrefTests: Helper {
  override func spec() {
    describe("parser") {
      let parser = Pro.getHref()
      let domain = "http://google.com"
      it("handles base case") {
        expect(input("href=" + domain, with: parser)).to(output(domain))
      }

      it("handles double quotes") {
        let href = "\"\(domain)\""
        expect(input("href=" + href, with: parser)).to(output(domain))
      }

      it("should be able to contain single quotes if double are used") {
        let href = "\"\(domain)'''\""
        expect(input("href=" + href, with: parser)).to(output("\(domain)'''"))
      }

      // TODO: Handle invalid domains
//      it("handles single quotes") {
//        let href = "'\(domain)'"
//        expect(input("href=" + href, with: parser)).to(beFailing)
//      }
//
//      it("handles double quotes with no content") {
//        expect(input("href=\"\"", with: parser)).to(beFailing)
//      }
//
//      it("handles double quotes with no content") {
//        expect(input("href=''", with: parser)).to(beFailing)
//      }
    }
  }
}
