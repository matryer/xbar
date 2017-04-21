import SwiftCheck
@testable import BitBar

extension String {
  static func any(min: Int, max: Int) -> Gen<String> {
    return Character.arbitrary.proliferateRange(min, max).map { String($0) }
  }

  static func any(min: Int) -> Gen<String> {
    return Character.arbitrary.map { String($0) }.suchThat { $0.characters.count >= min }
  }

  static func any(empty: Bool) -> Gen<String> {
    if empty { return Character.arbitrary.map { String($0) } }
    return Character.arbitrary.proliferateNonEmpty.map { String($0) }
  }

  func blink(_ speed: Speed) -> String {
    switch speed {
    case .slow:
      return toAnsi(using: 5)
    case .rapid:
      return toAnsi(using: 6)
    case .none:
      return toAnsi(using: 25)
    }
  }

  var italic: String {
    return toAnsi(using: 3)
  }

  var bold: String {
    return toAnsi(using: 1)
  }

  var black: String {
    return toAnsi(using: 30)
  }

  var red: String {
    return toAnsi(using: 31)
  }

  var green: String {
    return toAnsi(using: 32)
  }

  var yellow: String {
    return toAnsi(using: 33)
  }
  var blue: String {
    return toAnsi(using: 34)
  }

  var magenta: String {
    return toAnsi(using: 35)
  }

  var cyan: String {
    return toAnsi(using: 36)
  }

  var white: String {
    return toAnsi(using: 37)
  }

  func background(color: CColor) -> String {
    return toColor(color: color, offset: 40)
  }

  func foreground(color: CColor) -> String {
    return toColor(color: color, offset: 30)
  }

  private func toColor(color: CColor, offset: Int) -> String {
    switch color {
    case .black:
      return toAnsi(using: 0 + offset)
    case .red:
      return toAnsi(using: 1 + offset)
    case .green:
      return toAnsi(using: 2 + offset)
    case .yellow:
      return toAnsi(using: 3 + offset)
    case .blue:
      return toAnsi(using: 4 + offset)
    case .magenta:
      return toAnsi(using: 5 + offset)
    case .cyan:
      return toAnsi(using: 6 + offset)
    case .white:
      return toAnsi(using: 7 + offset)
    case let .rgb(red, green, blue):
      return toAnsi(using: [red, green, blue])
    case let .index(color):
      return toAnsi(using: color)
    default:
      preconditionFailure("failed on default")
    }
  }

  func toAnsi(using code: Int, reset: Bool = true) -> String {
    return toAnsi(using: [code], reset: reset)
  }

  func toAnsi(using codes: [Int], reset: Bool = true) -> String {
    let code = "\033[\(codes.map(String.init).joined(separator: ";"))m\(self)"
    if reset { return code + "\033[0m" }
    return code
  }
}
