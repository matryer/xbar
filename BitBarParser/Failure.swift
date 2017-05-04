enum Failure: CustomStringConvertible {
  case negative
  case generic(String)
  case mismatch(String, String, String, String, String)

  public var description: String {
    switch self {
    case let .mismatch(line, input, remainder, expected, actual):
      return "Parser mismatch:"
      + "\nInput: \(input.inspected())"
      + "\nLine: \(line.inspected())"
      + "\nRemainder: \(remainder.inspected())"
      + "\nExpected: \(expected.inspected())"
      + "\nActual: \(actual.inspected())"
    default:
      return "TODO"
    }
  }
}
