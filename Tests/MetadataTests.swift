import Quick
import Nimble
@testable import BitBar

let example = [
  "# <bitbar.title>Title goes here</bitbar.title>",
  "# <bitbar.version>v1.0</bitbar.version>",
  "# <bitbar.author>Your Name</bitbar.author>",
  "# <bitbar.author.github>your-github-username</bitbar.author.github>",
  "# <bitbar.desc>Short description of what your plugin does.</bitbar.desc>",
  "# <bitbar.image>http://www.hosted-somewhere/pluginimage</bitbar.image>",
  "# <bitbar.dependencies>python,ruby,node</bitbar.dependencies>",
  "# <bitbar.abouturl>http://url-to-about.com/</bitbar.abouturl>"
].joined(separator: "\n")

class MetadataTests: Helper {
  override func spec() {
    describe("base case") {
      fit("should work") {
        self.match(Metadata.parser, example) { result in
          dump(result)
        }
      }
    }
  }
}
