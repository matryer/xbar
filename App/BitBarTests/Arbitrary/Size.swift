import SwiftCheck
@testable import BitBar

extension Size: Paramable {
  public var attribute: String { return "size" }

  public static var arbitrary: Gen<Size> {
    return Gen.compose { c in
      Size(c.generate(using: natrual))
    }
  }

  func test(_ size: Size) -> Property {
    return size.getValue() ==== self.getValue()
  }
}
