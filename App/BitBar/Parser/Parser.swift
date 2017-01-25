// swiftlint:disable type_name
// swiftlint:disable line_length
// swiftlint:disable type_body_length

import FootlessParser
public typealias P<T> = Parser<Character, T>

// TODO: Rename Pro to something like Parser
// Parser is currently taken by FootlessParser
class Pro {
  private static let ws = zeroOrMore(whitespace)
  private static let wsOrNl = zeroOrMore(whitespacesOrNewline)
  private static let endOfStream = "\n~~~"
  private static let menuDelimiter = "\n---\n"
  private static let endOfMenu = til(["|", endOfStream, "\n--", menuDelimiter])
  private static let everything = zeroOrMore(any())

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
    return Font.init <^> attribute("font") { quoteOrWord() }
  }

  /**
    Unquoted size attribute as a positive int, i.e size=10
  */
  internal static func getSize() -> P<Size> {
    return Size.init <^> attribute("size") { digits() }
  }

  /**
    Quote / unquoted bash attribute, i.e bash="/usr/local/bin space"
  */
  internal static func getBash() -> P<Bash> {
    return Bash.init <^> attribute("bash") { quoteOrWord() }
  }

  internal static func getTitle() -> P<Title> {
    let title = til([menuDelimiter, endOfStream, "|"])
    return curry(mergeTitle) <^> title <*> getParams() <*> zeroOrMore(getMenu())
  }

  internal static func getOutput() -> P<Output> {
    return curry(merge) <^> getTitle() <*> (hasStream() <* wsOrNl)
  }

  /**
    Replaces emojis with it whatever @replace returns
    I.e "Hello :mushroom:" => "Hello replace("mushroom")"
  */
  internal static func replaceEmojize(replace: @escaping (String) -> String?) -> P<String> {
    // TODO: What happens then there is no closing :?
    func merge(pre: String, item: String, post: String) -> String {
      guard let result = replace(item) else {
        return pre + ":" + item + ":" + post
      }

      return pre + result + post
    }

    let emojize =
      curry(merge) <^>
      (til([":"]) <* string(":")) <*>
      (til([":"]) <* string(":")) <*>
      til([":"])
    let parser: P<[String]> = zeroOrMore(emojize)
    return curry(self.merge) <^> parser <*> zeroOrMore(any())
  }

  /**
    A menu with zero or more parameters and zero or more sub menus
    I.e \n---\nMenu | terminal=true \n--A Sub Menu
  */
  internal static func getMenu() -> P<Menu> {
    let menu = string(menuDelimiter) *> endOfMenu
    let main: P<Menu> = curry(merge) <^> menu <*> (getParams() <* ws)
    return main >>- {
      return curry(merge) <^> pure($0) <*> zeroOrMore(getSubMenu2(pure($0), 1))
    }
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
  internal static func getANSIs() -> P<[Any]> {
    let term = til(["\u{1B}", "\\033", "\033", "\\e", "\\x1b"], empty: false)
    let del = string("\\033") <|> string("\\e") <|> string("\\x1b") <|> string("\033") <|> string("\u{1B}")
    let numbers: P<[Int]> = zeroOrMore(digits() <* optional(string(";")))
    let reme = del *> string("[") *> numbers <* string("m")
    let toA = { $0 as Any }
    // let rest = toA <^> oneOrMore(any())
    return zeroOrMore((toA <^> reme) <|> (toA <^> term))
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
    let bar = ws *> string("|") <* ws
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
    return bar *> zeroOrMore(item) <* ws
  }

  /**
    Color attribute with hex or color value, i.e color=red or color=#ff00AA
  */
  internal static func getColor() -> P<Color> {
    return ws *> string("color=") *> (hexColor() <|> regularColor())
  }

  /**
    Sub menu who´s depth is defined by @nextLevel, i.e \n----Sub Menu | terminal=true font=10
  */
  internal static func getSubMenu2(_ parent: P<Menu>, _ nextLevel: Int = 1) -> P<Menu> {
    let dashes = count(nextLevel * 2, char("-"))
    let notMenu: P<String> = count(1, noneOf([menuDelimiter]))
    let title = ws *> notMenu *> dashes *> endOfMenu
    let main: P<Menu> = curry(merge) <^> title <*> parent <*> getParams()
    return main >>- {
      return curry(merge) <^> pure($0) <*> zeroOrMore(lazy(getSubMenu2(pure($0), nextLevel + 1)))
    }
  }

  /**
    Sub menu who´s depth is defined by @nextLevel, i.e \n----Sub Menu | terminal=true font=10
  */
  internal static func getSubMenu(_ nextLevel: Int = 1) -> P<Menu> {
    let dashes = count(nextLevel * 2, char("-"))
    let notMenu: P<String> = count(1, noneOf([menuDelimiter]))
    return curry(merge) <^>
      (ws *> notMenu *> dashes *> endOfMenu) <*>
      pure(nextLevel) <*>
      getParams() <*>
      zeroOrMore(lazy(getSubMenu(nextLevel + 1)))
  }

  private static func getParams() -> P<[Param]> {
    return optional(getOneParam() <* ws, otherwise: [])
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
  private static func quote() -> P<String> {
    let quote = string("\"")
    return quote *> zeroOrMore(not("\"")) <* quote
  }

  // @example: "hello" or hello
  private static func quoteOrWord() -> P<String> {
    return quoteOr(word())
  }

  // Match everything between ' or " or the entire @parser
  // TODO: Handle escaped quotes
  private static func quoteOr(_ parser: P<String>) -> P<String> {
    return count(1, oneOf("\"'")) >>- { til([$0]) <* string($0) } <|> parser
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
    if empty {
      return zeroOrMore(parser)
    }

    return oneOrMore(parser)
  }

  // @example: "\n~~~" yields true
  private static func hasStream() -> P<Bool> {
    return wsOrNl *> ((string("~~~") *> pure(true)) <|> pure(false))
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
      // TODO: Fail if not the above
      return 100
    }
  }

  private static func merge(_ title: String, level: Int, _ params: [Param], _ menus: [Menu]) -> Menu {
    return Menu(title, params: params, menus: menus, level: level)
  }

  private static func mergeTitle(_ title: String, _ params: [Param], _ menus: [Menu]) -> Title {
    return Title(title, params: params, menus: menus)
  }

  private static func merge(_ title: String, _ parent: Menu, _ params: [Param]) -> Menu {
    return Menu(title, params: params, parent: parent)
  }

  private static func merge(_ menu: Menu, _ menus: [Menu]) -> Menu {
    menu.add(menus: menus)
    return menu
  }

  private static func merge(_ title: String, _ params: [Param], _ menus: [Menu]) -> Menu {
    return Menu(title, params: params, menus: menus)
  }

  private static func merge(_ title: String, _ params: [Param]) -> Menu {
    return Menu(title, params: params)
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
    return (head, row, string.distance(from: head.lowerBound, to: index) + 1)
  }

  private static func merge(emojis: [String], remaining: String) -> String {
    return emojis.joined(separator: "") + remaining
  }
}
