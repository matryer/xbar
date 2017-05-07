// swiftlint:disable type_name
// swiftlint:disable line_length
// swiftlint:disable type_body_length
import FootlessParser
import AppKit

// TODO: Rename Pro to something like Parser
// Parser is currently taken by FootlessParser
class Pro {
  private static let ws = zeroOrMore(whitespace)
  private static let wsOrNl = zeroOrMore(whitespacesOrNewline)
  private static let manager = NSFontManager.shared()
  private static let terminals = ["\u{1B}", "\\033", "\033", "\\e", "\\x1b"]
  internal static let slash = "\\"

  /**
    A file name on the form {name}.{int}{unit}.{ext}
    I.e a-file.10d.sh
  */
  internal static func getFile() -> P<File> {
    let time = curry(toTime) <^> digits() <*> count(1, oneOf("smhd"))
    let rest = oneOrMore(any())
    let name = til(["."], empty: false) <* string(".")
    let ext = string(".") *> rest
    return curry(File.init) <^> name <*> time <*> ext
  }

  // @example: "10" (as a string)
  private static func digitsAsString() -> P<String> {
    return oneOrMore(digit)
  }

  private static func digits() -> P<Int> {
    // TODO: Replace ! with stop(...)
    return { Int($0)! } <^> digitsAsString()
  }

  /**
    Apply @parser to a @string
    I.e parse(getFile(), "a-file.10d.sh")
  */
  public static func parse<T>(_ parser: P<T>, _ value: String) -> Result<T> {
    do {
      return Result.success(try FootlessParser.parse(parser, value), "")
    } catch ParseError<Character>.Mismatch(let remainder, let expected, let actual) {
      let index = value.index(value.endIndex, offsetBy: -Int(remainder.count))
      let (lineRange, row, pos) = position(of: index, in: value)
      let line = value[lineRange.lowerBound..<lineRange.upperBound].trimmingCharacters(in: CharacterSet.newlines)
      var lines = [String]()
      lines.append("An error occurred when parsing this line:")
      lines.append(line)
      lines.append(String(repeating: " ", count: pos) + "^")
      lines.append("\(row):\(pos) Expected '\(expected)', actual '\(actual)'")
      return Result.failure(lines)
    } catch (let error) {
      return Result.failure([String(describing: error)])
    }
  }

  private static func anyOf(_ these: [String]) -> P<String> {
    if these.isEmpty { preconditionFailure("Min 1 arg") }
    if these.count == 1 { return string(these[0]) }
    return these[1..<these.count].reduce(string(these[0])) { acc, str in
      return acc <|> string(str)
    }
  }

  internal static func until(_ oops: String, consume: Bool = true) -> P<String> {
    return until([oops], consume: consume)
  }

  internal static func until(_ oops: [String], consume: Bool = true) -> P<String> {
    let one: P<String> = count(1, any())
    let escaped: P<String> = string("\\")
    let terminator: P<String> = count(1, noneOf(oops))
    let block: P<String> = (curry({ (a: String, b: String) in unescape(a + b, what: oops) }) <^> escaped <*> one) <|> terminator
    let blocks = { (values: [String]) in values.joined() } <^> zeroOrMore(block)

    // Should we consume the last char we just matched against?
    // This is being used by the menu parser which needs the delimiter to deter. where the params list begins and ends.
    guard consume else {
      return blocks
    }

    return blocks <* anyOf(oops)
  }

  private static func til(_ values: [String], empty: Bool = true) -> P<String> {
    let parser = noneOf(values)
    if empty { return zeroOrMore(parser) }
    return oneOrMore(parser)
  }

  private static func toTime(_ value: Int, _ unit: String) -> Int {
    switch unit {
    case "s":
      return value
    case "m":
      return toTime(value * 60, "s")
    case "h":
      return toTime(value * 60, "m")
    case "d":
      return toTime(value * 24, "h")
    default:
      preconditionFailure("Invalid unit: \(unit)")
    }
  }

  private static func position(of index: String.CharacterView.Index, in string: String) -> (line: Range<String.CharacterView.Index>, row: Int, pos: Int) {
    var head = string.startIndex..<string.startIndex
    var row = 0
    while head.upperBound < index {
        head = string.lineRange(for: head.upperBound..<head.upperBound)
        row += 1
    }
    return (head, row, string.distance(from: head.lowerBound, to: index))
  }

  internal static func unescape(_ value: String, what: [String]) -> String {
    return ([slash] + what).reduce(value) {
      return $0.replace(slash + $1, $1)
    }
  }

  private static func stop <A, B>(_ message: String) -> Parser<A, B> {
    return Parser { parsedtokens in
      throw ParseError.Mismatch(parsedtokens, message, "done")
    }
  }
}
