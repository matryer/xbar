import SwiftCheck
@testable import BitBar

extension Output: Base {
  public func getInput() -> String {
    return title.getInput() + (isStream ? "\n~~~" : "")
  }

  func toString() -> String {
    return "title: " + title.toString() + "stream:" + String(isStream)
  }

  public static var arbitrary: Gen<Output> {
    return Gen.compose { c in
      return Output(c.generate(), c.generate())
    }
  }

  func test(_ output: Output) -> Property {
    return title.test(output.title) ^&&^ output.isStream ==== isStream
  }
}
