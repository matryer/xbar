import FootlessParser

extension Pro {
  internal static let ws = zeroOrMore(whitespace)
  static let nl = zeroOrMore(string("\n"))
  typealias Head = Raw.Head
  typealias Tail = Raw.Tail

  static var output: P<Head> {
    return curry({ (line, menus) in
      return Head(title: line.1, params: line.2, menus: menus)
    }) <^> line <*> menus
  }

  // @input: Title|, output: Title, rest: "|"
  // @input: Title---\n, output: Title, rest: ""
  // @input: Title\n, output: Title, rest: "\n"
  private static var title: P<String> {
    return until(["|", "\n"], consume: false)
  }

  // @input: --Title|param=1, output: 1, Title, {param: 1}, rest: ""
  // @input: -----\n, output: 1, ---\n, {}, rest: ""
  internal static var menu: P<Tail> {
    return { line in
      return Tail(level: line.0, title: line.1, params: line.2)
    } <^> line
  }

  internal static var line: P<(Int, String, [Raw.Param])> {
    return curry({ ($0, $1, $2) }) <^> level <*> text <*> params
  }

  internal static var menus: P<[Raw.Tail]> {
    return optional(string("---\n") *> zeroOrMore(menu), otherwise: [])
  }

  // @input: Title\n, output: Title, \n
  // @input: Title|param=1, output: Title, |param1
  // @input: Title\n~~~, output: Title, \n~~~
  static var text: P<String> {
    return until(["\n", "|"], consume: false)
  }

  // @input: -----\n, output: 2, -\n
  // @input: ---\n, output: 1, -\n
  // @input: \n, output: 0, \n
  internal static var level: P<Int> {
    return { $0.count } <^> zeroOrMore(string("--"))
  }

  // @example: #ff0011
  static var hexColor: P<Color> {
    return quoteAnd(Color.hex <^> (string("#") *> hex) <* ws)
  }

  // @example: red
  static var regularColor: P<Color> {
    return Color.name <^> quoteOrWord <* ws
  }

  static var float: P<Float> {
    let das = digitsAsString
    return curry({ a, b in "\(a).\(b)" }) <^> das <*> optional(string(".") *> das, otherwise: "0") >>- { maybe in
      if let float = Float(maybe) {
        return pure(float)
      }

      return stop("Could not parse \(maybe) as a float")
    }
  }

  // @example: "hello" or hello
  static var quoteOrWord: P<String> {
    return quoteOr(word)
  }

  // Match everything between ' or " or the entire @parser
  // TODO: Handle escaped quotes
  static func quoteOr(_ parser: P<String>) -> P<String> {
    return quote <|> parser
  }

  static func s(_ ss: String) -> P<String> {
    return string(ss)
  }

  static func add(_ a: P<String>, _ b: P<String>) -> P<String> {
    return a <* b
  }

  // @example: "10" (as a string)
  static var digitsAsString: P<String> {
    return oneOrMore(digit)
  }

  // @example: 10
  static var digits: P<Int> {
    return digitsAsString >>- { maybe in
      if let int = Int(maybe) {
        return pure(int)
      }

      return stop("Could not convert \(maybe) to int")
    }
  }

  // One or more characters without whitespace
  // @example: Hello
  static var word: P<String> {
    return oneOrMore(satisfy(expect: "word") { (char: Character) in
      return String(char).rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) == nil
    })
  }

  // @example: true
  static var bool: P<Bool> {
    return truthy <|> falsy
  }

  // @example: font=10
  static func attribute<T>(_ name: String, _ block: () -> P<T>) -> P<T> {
    return attribute(string(name), block)
  }

  // @example: font=10
  static func attribute<T>(_ name: P<String>, _ block: () -> P<T>) -> P<T> {
    return (ws *> (name *> ws *> string("=") *> ws) *> block() <* ws)
  }

  // @example: true
  static var truthy: P<Bool> {
    return quoteOr(string("true")) *> pure(true)
  }

  // @example: "FF00aa"
  static var hex: P<String> {
    return oneOrMore(digit <|> oneOf("ABCDEFabcdef"))
  }

  // @example: false
  static var falsy: P<Bool> {
    // FIXME: Check the value of bool within quotes. Same for truthy()
    return quoteOr(string("false")) *> pure(false)
  }

  // @example: "A B C"
  static var quote: P<String> {
    // TODO: Handle first char as escaped quote, i.e \"abc (same for quoteAnd)
    return oneOf("\"\'") >>- { (char: Character) in until(String(char)) }
  }

  /**
   XMenu params, i.e | terminal=false length=10
   */
  internal static var params: P<[Raw.Param]> {
    return optional(
      ws *> string("|") *>
      ws *> oneOrMore(ws *> param <* ws)
      <* ws, otherwise: []
    ) <* oneOrMore(string("\n"))
  }

  static var param: P<Param> {
    return length <|>
      alternate <|>
      checked <|>
      ansi <|>
      bash <|>
      dropdown <|>
      emojize <|>
      color <|>
      font <|>
      trim <|>
      arg <|>
      href <|>
      image <|>
      refresh <|>
      size <|>
      terminal
  }

  static var posNum: P<Int> {
    return digits >>- { digit in
      guard digit > 0 else {
        return stop("\(digit) must be a positive number")
      }

      return pure(digit)
    }
  }

  static func error(message: String, key: String, value: String) -> Param {
    return .error(message, key, value)
  }

  static func quoteAnd<T>(_ parser: P<T>) -> P<T> {
    return oneOf("\"\'") >>- { (char: Character) in
      return parser <* string(String(char))
      } <|> parser
  }

  static func toImage(forKey key: String, isTemplate: Bool) -> P<Param> {
    return { raw in
      guard let image = toImage(raw, isTemplate) else {
        return error(message: "base64 or href", key: key, value: raw)
      }

      return .image(image)
      } <^> attribute(key) { quoteOrWord }
  }

  static func toImage(_ raw: String, _ isTemplate: Bool) -> Image? {
    if let _ = toData(base64: raw) {
      return .base64(raw, isTemplate)
    } else if let _ = URL(string: raw) {
      return .href(raw, isTemplate)
    }

    return nil
  }

  static func toData(base64: String) -> Data? {
    let options = Data.Base64DecodingOptions(rawValue: 0)
    return Data(base64Encoded: base64, options: options)
  }
}
