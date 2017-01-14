import SwiftCheck
@testable import BitBar

extension Bash: Paramable {
  public var attribute: String { return "bash" }

  public static var arbitrary: Gen<Bash> {
    return Gen.compose { c in
      Bash(c.generate(using: aWord()))
    }
  }

  func test(_ bash: Bash) -> Property {
    return bash.getValue() ==== self.getValue()
  }
}
