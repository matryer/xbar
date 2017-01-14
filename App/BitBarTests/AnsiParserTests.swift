import Quick
import Nimble
@testable import BitBar

func read(file: String) -> String? {
  guard let data = NSData(contentsOfFile: file) else {
    return nil
  }

  return String(data: data as Data, encoding: String.Encoding.utf8)
}

class AnsiParserTests: QuickSpec {
  override func spec() {
    context("ANSI parser") {
      it("handles base case") {
        // TODO
      }
    }
  }
}
