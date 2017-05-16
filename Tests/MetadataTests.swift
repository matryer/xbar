import Quick
import Nimble
@testable import BitBar

let example = [
  "# <bitbar.title>A Title</bitbar.title>",
  "# <bitbar.version>v10.10.10</bitbar.version>",
  "# <bitbar.author>Your Name</bitbar.author>",
  "# <bitbar.author.github>your-github-username</bitbar.author.github>",
  "# <bitbar.desc>Short description of what your plugin does.</bitbar.desc>",
  "# <bitbar.image>http://www.hosted-somewhere/pluginimage</bitbar.image>",
  "# <bitbar.dependencies>python,ruby,node</bitbar.dependencies>",
  "# <bitbar.abouturl>http://url-to-about.com/</bitbar.abouturl>",
  "# <bitbar.droptypes>filenames,public.url</bitbar.droptypes>",
  "# <bitbar.demo>A B C</bitbar.demo>"
].joined(separator: "\n")

class MetadataTests: Helper {
  override func spec() {
    describe("valid meta data") {
      it("should handle working example") {
        switch Metadata.parse(example) {
        case let .success(data):
          expect(data.count).to(equal(10))
          for meta in data {
            switch meta {
            case let .title(title):
              expect(title).to(equal("A Title"))
            case let .version(version):
              expect(version).to(equal("v10.10.10"))
            case let .author(author):
              expect(author).to(equal("Your Name"))
            case let .github(github):
              expect(github).to(equal("your-github-username"))
            case let .description(desc):
              expect(desc).to(equal("Short description of what your plugin does."))
            case let .image(url):
              expect(url).to(equal(URL(string: "http://www.hosted-somewhere/pluginimage")))
            case let .dependencies(list):
              expect(list).to(equal(["python", "ruby", "node"]))
            case let .about(content):
              expect(content).to(equal(URL(string: "http://url-to-about.com/")))
            case let .dropTypes(list):
              expect(list).to(equal(["filenames", "public.url"]))
            case let .demoArgs(list):
              expect(list).to(equal(["A", "B", "C"]))
            }
          }
        case let .failure(data):
          fail("Failed: \(data)")
        }
      }
    }

    describe("from file") {
      it("should read existing file with metadata") {
        expect(try! Metadata.from(path: toFile("metadata.sh"))).to(haveCount(8))
      }

      it("should handle file without metadata") {
        expect(try! Metadata.from(path: toFile("version-env.sh"))).to(haveCount(0))
      }
    }
  }
}
