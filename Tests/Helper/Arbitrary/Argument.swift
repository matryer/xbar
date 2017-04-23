import SwiftCheck
@testable import BitBar

extension Argument: Base {
  public static func ==(lhs: Argument, rhs: Argument) -> Bool {
    return lhs.key == rhs.key && lhs.value == rhs.value
  }

  func getInput() -> String {
    return "param\(key)=\(escape(value))"
  }

  static let head: Gen<Int> = (0...10000).any

  public static var arbitrary: Gen<Argument> {
    return Gen.compose { c in
      return Argument(
        key: c.generate(using: head),
        value: c.generate(using: String.any(empty: false))
      )
    }
  }

  // TODO: Move
  func escape(_ value: String, quote: String = "\"") -> String {
    return quote + value.replace("\\", "\\\\").replace(quote, "\\" + quote) + quote
  }
}
