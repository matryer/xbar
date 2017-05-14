import Files
import FootlessParser
import AppKit

class File {
  internal static let slash = "\\"
  private init() {}
  struct FileError: Error, CustomStringConvertible {
    let file: String

    public var description: String {
      return "Could not read file name from '\(file)'"
    }
  }

  public enum Result<T> {
    case failure([String])
    case success(T)
  }

  enum Mode {
    case stream(String)
    case timer(String, Double)
  }

  static func toPlugin(file: Files.File, delegate: Managable) throws -> Plugin {
    switch File.parse(File.parser, file.name) {
    case let .success(.stream(name)):
      return StreamablePlugin(name: name, file: file, manager: delegate)
    case let .success(.timer(name, interval)):
      return ExecutablePlugin(name: name, interval: interval, file: file, manager: delegate)
    case .failure:
      throw FileError(file: file.name)
    }
  }

  static public func join(_ paths: String...) -> String {
    if paths.isEmpty { fatalError("Min 1 path, got zero") }
    if paths.count == 1 { return paths[0] }
    return paths[1..<paths.count].reduce(paths[0]) {
      URL(fileURLWithPath: $0).appendingPathComponent($1).path
    } as String
  }

  static var resourcesPath: String {
    return Bundle.main.resourcePath!
  }

  static func from(resource file: String) -> String {
    return join(resourcesPath, file)
  }

  /**
    A file name on the form {name}.{int}{unit}.{ext}
    I.e a-file.10d.sh
  */
  static var parser: P<Mode> {
    // Stram: name.stream.sh
    // exec: name.10s.sh
    let name = til(["."], empty: false) <* string(".")
    let time = curry({ ($0, $1) }) <^> digits() <*> count(1, oneOf("smhd")) >>- toTime
    return (name >>- { name in
      let s = pure(Mode.stream(name)) <* string("stream")
      let e = { Mode.timer(name, Double($0)) } <^> time
      return s <|> e
    }) <* (string(".") <* oneOrMore(any()))
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
      return Result.success(try FootlessParser.parse(parser, value))
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
    if these.isEmpty { preconditionFailure("[Bug] Min 1 arg") }
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

  private static func toTime(value: (Int, String)) -> P<Int> {
    switch value {
    case let (time, "s"):
      return pure(time)
    case let (time, "m"):
      return pure(time * 60)
    case let (time, "h"):
      return pure(time * 60 * 60)
    case let (time, "d"):
      return pure(time * 24 * 60 * 60)
    default:
      return stop("Invalid unit '\(value.0)'")
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
