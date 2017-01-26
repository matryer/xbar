import SwiftCheck
@testable import BitBar

extension Bash: Paramable {
  public static var arbitrary: Gen<Bash> {
    return Gen.compose { c in
      Bash(c.generate(using: aWord()))
    }
  }

  func test(_ bash: Bash) -> Property {
    return bash ==== self
  }

  public static func == (lhs: Bash, rhs: Bash) -> Bool {
    return lhs.equals(rhs)
  }
}
