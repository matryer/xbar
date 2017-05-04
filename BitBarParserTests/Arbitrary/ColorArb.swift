import SwiftCheck
@testable import BitBarParser

extension Color: Arbitrary {
  public static var arbitrary: Gen<Color> {
    return [
      hexValue.map(Color.hex),
      string.map(Color.name)
    ].one()
  }

  var output: String {
    switch self {
    case let .hex(value):
      return "color=#\(value)"
    case let .name(name):
      return "color=\(name.quoted())"
    }
  }
}
