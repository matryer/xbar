// swiftlint:disable type_name
// swiftlint:disable line_length
// swiftlint:disable type_body_length
import Hue
import FootlessParser
import AppKit

typealias X = (String, [Param], Int)
public typealias P<T> = Parser<Character, T>
typealias U = P<X>

let slash = "\\"
public func unescape(_ value: String, what: [String]) -> String {
return ([slash] + what).reduce(value) {
    return $0.replace(slash + $1, $1)
  }
}

// TODO: Rename Pro to something like Parser
// Parser is currently taken by FootlessParser
class Pro {
  private static let ws = zeroOrMore(whitespace)
  private static let wsOrNl = zeroOrMore(whitespacesOrNewline)
  private static let manager = NSFontManager.shared()
  private static let terminals = ["\u{1B}", "\\033", "\033", "\\e", "\\x1b"]

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

  /**
    Quote / unquoted href attribute, i.e href="http://google.com"
  */
  internal static func getHref() -> P<Href> {
    return Href.init <^> attribute("href") { quoteOrWord() }
  }

  /**
    Quote / unquoted font attribute, i.e font="Monaco"
  */
  internal static func getFont() -> P<Font> {
    return attribute("font") { quoteOrWord() } >>- { font in
      let has = manager.availableFontFamilies.some {
        return $0.lowercased() == font.lowercased()
      }

      if has { return pure(Font(font)) }

      return stop("Can't find font \(font) in the list of fonts")
    }
  }

  /**
    Unquoted size attribute as a positive int, i.e size=10
  */
  internal static func getSize() -> P<Size> {
    return attribute("size") { digits() } >>- { size in
      if size == 0 { return stop("Invalid size 0") }
      return pure(Size(size))
    }
  }

  /**
    Quote / unquoted bash attribute, i.e bash="/usr/local/bin space"
  */
  internal static func getBash() -> P<Bash> {
    return Bash.init <^> attribute("bash") { quoteOrWord() }
  }

  internal static var title: P<Title> {
    return curry({
      handle(head:
        toValue(with: -1, for: $0), menus: $1)
      }
    ) <^> heading <*> menus
  }

  static func toValue(with: Int, for xs: X) -> Source {
    return .item((xs.0, xs.1), with, [Source]())
  }

  static func handle(head: Source, menus: [Source]) -> Title {
    return toTitle(head.appended(menus))
  }

  static func toMenu(head: Source, menus: [Source]) -> Menu {
    return toMenu(head.appended(menus))
  }

  static func toTitle(_ source: Source) -> Title {
    switch source {
    case let .item((title, params), _, menus):
      return Title(title, container: Container(params: params), menus: menus.map { toMenu($0) })
    }
  }

  static func toMenu(_ menu: Source) -> Menu {
    switch menu {
    case let .item((title, params), level, menus):
      return Menu(title, container: Container(params: params), menus: menus.map { toMenu($0) }, level: level)
    }
  }

  internal static var menus: P<[Source]> {
    func forEach(_ menus: [X]) -> [Source] {
      return menus.map { return toValue($0) }
    }
    return forEach <^> optional(string("---\n") *> headings, otherwise: [X]())
  }

  static func toValue(_ head: X) -> Source {
    return .item((head.0, head.1), head.2, [Source]())
  }

  // TODO: Use title instead of getTitle
  internal static func getTitle() -> P<Title> {
    return title
  }

  internal static func getOutput() -> P<Output> {
    return curry(merge) <^> getTitle() <*> (wsOrNl *> hasStream() <* wsOrNl)
  }

  /**
    A menu with zero or more parameters and zero or more sub menus
    I.e \n---\nMenu | terminal=true \n--A Sub Menu
  */
  internal static func getMenu() -> P<Menu> {
    return menu
  }

  /**
    Boolean ansi attribute, i.e ansi=false
  */
  internal static func getAnsi() -> P<Ansi> {
    return Ansi.init <^> attribute("ansi") { bool() }
  }

  /**
    Boolean emojize attribute, i.e emojize=false
  */
  internal static func getEmojize() -> P<Emojize> {
    return Emojize.init <^> attribute("emojize") { bool() }
  }

  /**
    Quote / unquoted templateImage attribute, i.e templateImage="c2Rm=="
  */
  internal static func getTemplateImage() -> P<Image> {
    return curry(Image.init) <^> attribute("templateImage") { quoteOrWord() } <*> pure(true)
  }

  /**
    Quote / unquoted image attribute, i.e image="c2Rm=="
  */
  internal static func getImage() -> P<Image> {
    return Image.init <^> attribute("image") { quoteOrWord() }
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

  /**
    Reads ANSI codes, i.e "\e[10mHello\e[0;2m" => [[10], "Hello", [0, 2]]
  */
  internal static func getANSIs() -> P<[Value]> {
    return Ansi.toAttr <^> zeroOrMore(notAnsi <|> ansi)
  }

  // Anything but \e[...m
  private static var notAnsi: P<Attributed> {
    return { .string($0) } <^> til(terminals, empty: false)
  }

  // Input: 5;123, output: Color.index(123)
  private static var ansi: P<Attributed> {
    let delimiters: P<String> = anyOf(terminals)
    return { .codes($0) } <^> (delimiters *> string("[") *> (colorWithArgs <|> codesWithDel) <* string("m"))
  }

  // Handles 256 true colors and rgb
  private static var colorWithArgs: P<[Code]> {
    let code = (string("48") <|> string("38")) <* string(";")
    return curry({ [toCode($0, $1)] }) <^> code <*> (c256 <|> rgb)
  }

  // Input: 5;123, output: Color.index(123)
  private static var c256: P<CColor> {
    return { .index($0) } <^> (string("5;") *> digits())
  }

  // Input: 2;10;20;30, output: Color.rgb(10, 20, 30)
  private static var rgb: P<CColor> {
    let codes = count(3, (string(";") *> digits()))
    return { .rgb($0[0], $0[1], $0[2]) } <^> (string("2") *> codes)
  }

  // Input: 10;, output: 10
  private static var code: P<Int> {
    return digits() <* optional(string(";"))
  }

  // Input: 10;20;30, output: [.color(10), .bold(20), .blink(false)]
  private static var codesWithDel: P<[Code]> {
    return zeroOrMore(code) >>- { (codes: [Int]) in
      var nums = [Code]()
      for code in codes {
        if let found = Ansi.toCode(code) {
          nums.append(found)
        } else {
          return stop("Invalid number \(code)")
        }
      }

      return pure(nums)
    }
  }

  private static func anyOf(_ these: [String]) -> P<String> {
    if these.isEmpty { preconditionFailure("Min 1 arg") }
    if these.count == 1 { return string(these[0]) }
    return these[1..<these.count].reduce(string(these[0])) { acc, str in
      return acc <|> string(str)
    }
  }

  private static func toCode(_ location: String, _ color: CColor) -> Code {
    switch location {
    case "38":
      return .color(.foreground, color)
    case "48":
      return .color(.background, color)
    default:
      preconditionFailure("Invalid location \(location)")
    }
  }

  /**
    Boolean alternate attribute, i.e alternate=false
  */
  internal static func getAlternate() -> P<Alternate> {
    return Alternate.init <^> attribute("alternate") { bool() }
  }

  /**
    Boolean checked attribute, i.e checked=true
  */
  internal static func getChecked() -> P<Checked> {
    return Checked.init <^> attribute("checked") { bool() }
  }

  /**
    Boolean trim attribute, i.e trim=false
  */
  internal static func getTrim() -> P<Trim> {
    return Trim.init <^> attribute("trim") { bool() }
  }

  /**
    Boolean dropdown attribute, i.e dropdown=false
  */
  internal static func getDropdown() -> P<Dropdown> {
    return Dropdown.init <^> attribute("dropdown") { bool() }
  }

  /**
    Boolean refresh attribute, i.e refresh=false
  */
  internal static func getRefresh() -> P<Refresh> {
    return Refresh.init <^> attribute("refresh") { bool() }
  }

  /**
    Boolean terminal attribute, i.e terminal=false
  */
  internal static func getTerminal() -> P<Terminal> {
    return Terminal.init <^> attribute("terminal") { bool() }
  }

  /**
    Named param with a quoted / unquoted value, i.e param12="A value"
  */
  internal static func getParam() -> P<NamedParam> {
    let param: P<String> = string("param") *> digitsAsString()
    let key = ws *> param <* string("=")
    let value = quoteOrWord() <* ws
    return curry(NamedParam.init) <^> key <*> value
  }

  /**
    Int length attribute, i.e length=11
  */
  internal static func getLength() -> P<Length> {
    return Length.init <^> attribute("length") { digits() }
  }

  /**
    Menu params, i.e | terminal=false length=10
  */
  internal static func getOneParam() -> P<[Param]> {
    let tc = { $0 as Param }
    let item =
      (tc <^> getLength()) <|>
      (tc <^> getAlternate()) <|>
      (tc <^> getChecked()) <|>
      (tc <^> getAnsi()) <|>
      (tc <^> getBash()) <|>
      (tc <^> getDropdown()) <|>
      (tc <^> getEmojize()) <|>
      (tc <^> getColor()) <|>
      (tc <^> getFont()) <|>
      (tc <^> getHref()) <|>
      (tc <^> getImage()) <|>
      (tc <^> getRefresh()) <|>
      (tc <^> getSize()) <|>
      (tc <^> getTemplateImage()) <|>
      (tc <^> getTerminal()) <|>
      (tc <^> getParam()) <|>
      (tc <^> getTrim())
    return ws *> string("|") *> ws *> oneOrMore(item) <* ws
  }

  /**
    Color attribute with hex or color value, i.e color=red or color=#ff00AA
  */
  internal static func getColor() -> P<Color> {
    return ws *> string("color=") *> (hexColor() <|> regularColor())
  }

  static var flat: P<(String, [Param])> {
    let terminals = ["\n", "|", "~~~"]
    let until2 = until(terminals, consume: false)
    return curry({ a, b in (a, b)}) <^> until2 <*> (params <* oneOrMore(string("\n")))
  }

  // TODO: Remove level
  static func headingFor(level: Int) -> U {
    return zeroOrMore(string("--")) >>- { indent in
      return { thing in
        toThing(value: thing.0, params: thing.1, level: indent.count)
      } <^> flat
    }
  }

  // FIXME: Rename to something better
  static private func toThing(value: String, params: [Param], level: Int) -> X {
    switch (value, level) {
    case ("-", 0): // Normal separator on level 0
      return (value, params, level)
    case ("-", _): // ---
      return (value, params, level - 1)
    case (_, _): // ---
      return (value, params, level)
    }
  }

  static func add(result1: [X], result2: [X]) -> [X] {
    return result1 + result2
  }

  static var headings: P<[X]> {
    return headingsFor(level: 0)
  }

  static var heading: P<X> {
    return headingFor(level: 0)
  }

  static func headingsFor(level: Int) -> P<[X]> {
    return zeroOrMore(headingFor(level: level))
  }

  static func merge(a: [X], b: [X], c: [X]) -> [X] {
    return a + b + c
  }

  /**
    Sub menu who´s depth is defined by @nextLevel, i.e \n----Sub Menu | terminal=true font=10
  */
  internal static func getSubMenu(_ nextLevel: Int = 1) -> P<Menu> {
    return submenu
  }

  internal static var menu: P<Menu> {
    return curry(toMenu) <^> heading <*> headingsFor(level: 1)
  }

  internal static var submenu: P<Menu> {
    return curry(toMenu) <^> headingFor(level: 1) <*> headingsFor(level: 2)
  }

  static func toMenu(head: X, tails: [X]) -> Menu {
    return toMenu(head: toValue(head), menus: tails.map { toValue($0) })
  }

  private static func getParams() -> P<[Param]> {
    return optional(getOneParam(), otherwise: [])
  }

  private static var params: P<[Param]> {
    return getParams()
  }

  // @example: true
  private static func truthy() -> P<Bool> {
    return string("true") *> pure(true)
  }

  // @example: "FF00aa"
  private static func hex() -> P<String> {
    return zeroOrMore(digit <|> oneOf("ABCDEFabcdef"))
  }

  // @example: false
  private static func falsy() -> P<Bool> {
    return string("false") *> pure(false)
  }

  // @example: "A B C"
  internal static func quote() -> P<String> {
    return oneOf("\"\'") >>- { (char: Character) in until(String(char)) }
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

  // @example: "hello" or hello
  private static func quoteOrWord() -> P<String> {
    return quoteOr(word())
  }

  // Match everything between ' or " or the entire @parser
  // TODO: Handle escaped quotes
  private static func quoteOr(_ parser: P<String>) -> P<String> {
    return (quote() <|> parser)
  }

  // @example: "10" (as a string)
  private static func digitsAsString() -> P<String> {
    return oneOrMore(digit)
  }

  // @example: 10
  private static func digits() -> P<Int> {
    return { Int($0)! } <^> digitsAsString()
  }

  // One or more characters without whitespace
  // @example: Hello
  private static func word() -> P<String> {
    return oneOrMore(satisfy(expect: "word") { (char: Character) in
      return String(char).rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) == nil
    })
  }

  // @example: true
  private static func bool() -> P<Bool> {
    return (truthy() <|> falsy())
  }

  // @example: font=10
  private static func attribute<T>(_ name: String, _ block: () -> P<T>) -> P<T> {
    return attribute(string(name), block)
  }

  // @example: font=10
  private static func attribute<T>(_ name: P<String>, _ block: () -> P<T>) -> P<T> {
    let equal = string("=")
    return (ws *> (name *> ws *> equal *> ws) *> block() <* ws)
  }

  private static func til(_ values: [String], empty: Bool = true) -> P<String> {
    let parser = noneOf(values)
    if empty { return zeroOrMore(parser) }
    return oneOrMore(parser)
  }

  // @example: "\n~~~" yields true
  private static func hasStream() -> P<Bool> {
    return ws *> ((string("~~~\n") *> pure(true)) <|> pure(false))
  }

  // @example: #ff0011
  private static func hexColor() -> P<Color> {
    return { Color.init(withHex: "#" + $0) } <^> (string("#") *> hex() <* ws)
  }

  // @example: red
  private static func regularColor() -> P<Color> {
    return { Color.init(withName: $0) } <^> quoteOrWord() <* ws
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

  private static func merge(title: Title, isStream: Bool) -> Output {
    return Output(title, isStream)
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
}
