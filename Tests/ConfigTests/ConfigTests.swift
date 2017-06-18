import Quick
import Nimble
@testable import Config

class ConfigTests: QuickSpec {
  override func spec() {
    dump(try! loadConfigFile())
  }
}
