import Quick
import Nimble
@testable import BitBar

class BufferTests: Helper {
  override func spec() {
    App.startedTesting()

    it("defaults to not finished") {
      expect(Buffer().isFinish()).to(beFalse())
    }

    it("defaults to empty") {
      expect(Buffer().toString()).to(beEmpty())
    }

    it("contains data") {
      let buffer = Buffer()
      buffer.append(string: "ABC")
      expect(buffer.toString()).to(equal("ABC"))
    }

    it("resets store") {
      let buffer = Buffer()
      buffer.append(string: "ABC")
      expect(buffer.reset()).to(equal("ABC"))
      expect(buffer.toString()).to(equal(""))
    }
  }
}
