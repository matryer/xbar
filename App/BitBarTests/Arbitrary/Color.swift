import SwiftCheck
@testable import BitBar

extension BitBar.Color: Paramable {
  public var attribute: String { return "color" }

  public static var arbitrary: Gen<Color> {
    let color1 = hexValue.map { Color(withHex: "#" + $0) }
    let color2 = anyOf("red", "gren", "blue", "yellow").map { Color(withName: $0) }
    return Gen<Color>.one(of: [color1, color2])
  }

  func test(_ color: Color) -> Property {
    return color.getValue() ==== self.getValue()
  }
}
