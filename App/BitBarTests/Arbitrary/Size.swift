import SwiftCheck
@testable import BitBar

extension Size: Paramable {
  public static var arbitrary: Gen<Size> {
    return Gen.compose { c in
      Size(c.generate(using: natrual))
    }
  }

  func test(_ size: Size) -> Property {
    return size ==== self
  }

  public static func == (lhs: Size, rhs: Size) -> Bool {
    return lhs.equals(rhs)
  }
}
