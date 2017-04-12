import SwiftCheck
@testable import BitBar

extension BitBar.Color: Paramable {
  public static var arbitrary: Gen<Color> {
    let color1 = hexValue.map { Color(withHex: "#" + $0) }
    let color2 = anyOf("red", "gren", "blue", "yellow").map { Color(withName: $0) }
    return Gen<Color>.one(of: [color1, color2])
  }

  func test(_ color: BitBar.Color) -> Property {
    return color ==== self
  }

  public static func == (lhs: BitBar.Color, rhs: BitBar.Color) -> Bool {
    return lhs.equals(rhs)
  }
}
