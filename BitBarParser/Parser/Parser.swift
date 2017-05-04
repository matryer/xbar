import FootlessParser

class Pro {
  typealias Index = String.CharacterView.Index
  static let slash = "\\"

  /**
   Apply @parser to a @string
   I.e parse(getFile(), "a-file.10d.sh")
   */
  public static func parse<T>(_ parser: P<T>, _ input: String) -> Result<T> {
    do {
      return .success(try FootlessParser.parse(parser, input))
    } catch ParseError<Character>.Mismatch(let remainder, let expected, let actual) {
      let index = input.index(input.endIndex, offsetBy: -Int(remainder.count))
      let (range, _, _) = position(of: index, in: input)
      let line = input[range.lowerBound..<range.upperBound]
        .trimmingCharacters(in: CharacterSet.newlines)
      return .failure(.mismatch(line, input, String(remainder), expected, actual))
    } catch CountError.NegativeCount {
      return .failure(.negative)
    } catch let error {
      return .failure(.generic(String(describing: error)))
    }
  }

  private static func anyOf(_ these: [String]) -> P<String> {
    if these.isEmpty { preconditionFailure("Min 1 arg") }
    if these.count == 1 { return string(these[0]) }
    return these[1..<these.count].reduce(string(these[0])) { acc, str in
      return acc <|> string(str)
    }
  }

  internal static func until(_ what: String, consume: Bool = true) -> P<String> {
    return until([what], consume: consume)
  }

  internal static func until(_ what: [String], consume: Bool = true) -> P<String> {
    let one: P<String> = count(1, any())
    let escaped: P<String> = string("\\")
    let terminator: P<String> = count(1, noneOf(what))
    let block: P<String> = (curry({ (a: String, b: String) in unescape(a + b, what: what) }) <^> escaped <*> one) <|> terminator
    let blocks = { (values: [String]) in values.joined() } <^> zeroOrMore(block)

    // Should we consume the last char we just matched against?
    // This is being used by the menu parser which needs the delimiter to deter. where the params list begins and ends.
    guard consume else {
      return blocks
    }

    return blocks <* anyOf(what)
  }

  private static func til(_ values: [String], empty: Bool = true) -> P<String> {
    let parser = noneOf(values)
    if empty { return zeroOrMore(parser) }
    return oneOrMore(parser)
  }

  private static func position(of index: Index, in string: String)
    -> (line: Range<Index>, row: Int, pos: Int) {
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
    }//.replace("\\", "")
    // return value.
  }

  internal static func stop<A, B>(_ message: String) -> Parser<A, B> {
    return Parser { parsedtokens in
      throw ParseError.Mismatch(parsedtokens, message, "Stop")
    }
  }
}
