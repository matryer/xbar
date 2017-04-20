import SwiftCheck
@testable import BitBar

extension BitBar.Color: ParamBase {
  public static var arbitrary: Gen<Color> {
    let color1 = hexValue.map { Color(hex: "#" + $0)! }
    let color2 = colors.any.map { Color(name: $0)! }
    return Gen<Color>.one(of: [color1, color2])
  }

  private static var colors: [String] {
    return Array(names.keys)
  }
}
