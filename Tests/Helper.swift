import SwiftCheck
import Quick
import Swift
import Nimble
@testable import BitBar

extension Array {
  var any: Gen<Element> {
    return Gen<Element>.fromElements(of: self)
  }
}

extension CountableClosedRange where Iterator.Element: RandomType  {
  var any: Gen<Element> {
    return Gen<Element>.fromElements(in: first!...last!)
  }
}

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
}




let slash = "\\"

// -- dex
func escape(char: String) -> String {
  let count = char.characters.count
  guard count == 1 else {
    preconditionFailure("Char length must be one, not \(count)")
  }
  // FIXME: Can we do this better?
  return char.replace(char, slash + char)
}

func escape(title: String, what: [String]) -> String {
  return ([slash] + what).reduce(title) { title, what in
    return title.replace(what, escape(char: what))
  }
}

func escape(title: String) -> String {
  return escape(title: title, what: ["|", "\n"])
}

func equal(_ value: String) -> MatcherFunc<Value> {
  return MatcherFunc { actual, failure in
    guard let result = try actual.evaluate() else {
      return false
    }

    switch result {
    case let (other, _):
      return other == value
    }
  }
}

func the<T: Menuable>(_ parser: P<T> , with input: String) -> W<String> {
  switch Pro.parse(parser, input) {
  case let Result.success(result, _):
    return .success(result.headline.string)
  case Result.failure(_):
    return .failure
  }
}

let failed = false <?> "Parser failed"
let upper: Gen<Character> = Gen<Character>.fromElements(in: "A"..."Z")
let lower: Gen<Character> = Gen<Character>.fromElements(in: "a"..."z")
let natrual = Int.arbitrary.suchThat { $0 > 0 }
let numeric: Gen<Character> = Gen<Character>.fromElements(in: "0"..."9")
let upperAF: Gen<Character> = Gen<Character>.fromElements(in: "A"..."F")
let loweraf: Gen<Character> = Gen<Character>.fromElements(in: "a"..."f")
let hexValue = Gen<Int>.choose((1, 6)).flatMap {
  return toString(upperAF, loweraf, numeric, size: $0)
}
let special: Gen<Character> = Gen<Character>.fromElements(of:
    ["!", "#", "$", "%", "&", "*", "+", "-", "/",
      "=", "?", "^", "_", "`", "{", "}", "~", "."
])
let char: Gen<Character> = Gen<Character>.one(of: [
  lower,
  numeric,
  special,
  upper
])
let suffix = anyOf("=", "==", "")
let base64 = glue([toString(upperAF, loweraf, numeric), suffix])


extension String {
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

// Helper function
public func tester<T>(_ post: String, block: @escaping (T) -> Any) -> MatcherFunc<T> {
  return MatcherFunc { actual, failure in
    failure.postfixMessage = post
    guard let result = try actual.evaluate() else {
      return false
    }

    let out = block(result)
    switch out {
    case is String:
      failure.postfixActual = out as! String
      return false
    case is Bool:
      return out as! Bool
    default:
      preconditionFailure("Invalid data, expected String or Bool got (type(of: out))")
    }
  }
}

// expect("ABC".bold).to(beItalic())
public func beItalic() -> MatcherFunc<Value> {
  return test(expect: .italic(true), label: "italic")
}

// expect("ABC".bold).to(beBold())
public func beBold() -> MatcherFunc<Value> {
  return test(expect: .bold(true), label: "bold")
}

// Helper function
public func test(expect: Code, label: String) -> MatcherFunc<Value> {
  return tester(label) { (_, codes) in
    for actual in codes {
      if actual == expect {
        return true
      }
    }

    return "not " + label
  }
}

// expect("ABC").to(have(color: 10))
public func have(color actual: Int) -> MatcherFunc<Value> {
  return test(expect: .color(.foreground, .index(actual)), label: "256 color")
}

// expect("ABC").to(have(background: 10))
public func have(background actual: Int) -> MatcherFunc<Value> {
  return test(expect: .color(.background, .index(actual)), label: "256 background color")
}

// expect("ABC").to(have(background: [10, 20, 30]))
public func have(background colors: [Int]) -> MatcherFunc<Value> {
  if colors.count != 3 { preconditionFailure("Rgb must contain 3 ints") }
  let expect: Code = .color(.background, .rgb(colors[0], colors[1], colors[2]))
  return test(expect: expect, label: "RGB background color")
}

// expect("ABC").to(have(rgb: [10, 20, 30]))
public func have(rgb colors: [Int]) -> MatcherFunc<Value> {
  if colors.count != 3 { preconditionFailure("Rgb must contain 3 ints") }
  let expect: Code = .color(.foreground, .rgb(colors[0], colors[1], colors[2]))
  return test(expect: expect, label: "RGB foreground color")
}

// expect("ABC").to(haveNoStyle())
public func haveNoStyle() -> MatcherFunc<Value> {
  return tester("no style") { (_, codes) in
    return codes.isEmpty
  }
}

// expect("ABC".blink).to(blink())
public func blink(_ speed: Speed) -> MatcherFunc<Value> {
  return test(expect: .blink(speed), label: "blink")
}

// expect("ABC").to(haveUnderline())
public func haveUnderline() -> MatcherFunc<Value> {
  return test(expect: .underline(true), label: "underline")
}

// expect("ABC".red).to(be(.red))
public func be(_ color: CColor) -> MatcherFunc<Value> {
  return test(expect: .color(.foreground, color), label: "color")
}

// expect("ABC".background(color: .red)).to(have(background: .red))
public func have(background color: CColor) -> MatcherFunc<Value> {
  return test(expect: .color(.background, color), label: "color")
}

func toString(_ gens: Gen<Character>..., size: Int = 3) -> Gen<String> {
  return Gen<Character>.one(of: gens).proliferateRange(1, size).map { String.init($0) }
}

func anyOf(_ values: String...) -> Gen<String> {
  return Gen<String>.one(of: values.map { Gen.pure($0) })
}

func glue(_ parts: [Gen<String>]) -> Gen<String> {
	return sequence(parts).map { $0.reduce("", +) }
}

func inspect(_ value: String) -> String {
  return "'" + value.replace("\n", "\\n").replace("'", "\\'") + "'"
}

public func beASuccess(with exp: String? = nil) -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "exit with status 0 and output '\(exp ?? "")'"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch (result, exp) {
    case (.success(_, 0), .none):
      return true
    case let (.success(stdout, 0), .some(exp)) where stdout == exp:
      return true
    default:
      failureMessage.postfixActual = String(describing: result)
      return false
    }
  }
}


public func the<T: Menuable>(_ parser: P<T> , with input: String) -> String {
  switch Pro.parse(parser, input) {
  case let Result.success(result, _):
    return result.headline.string
  case let Result.failure(lines):
    return "[Failure] " + lines.joined(separator: "")
  }
}

public func the<T: Paramable>(_ parser: P<T> , with: String) -> W<String> {
  return input(with, with: parser)
}

//public func input<T>(_ input: String, with parser: P<T>) -> W<String> {
//  return the(parser, with: input)
//}

// Just an alias for equal()
// public func output(_ value: String) -> MatcherFunc<String> {
//   return MatcherFunc { actual, failure in
//     guard let result = try actual.evaluate() else {
//       return false
//     }
//
//     return result == value
//   }
// }

// public func output(font name: String) -> MatcherFunc<W<Font>> {
//   return MatcherFunc { actual, failure in
//     failure.postfixMessage = "output font name \(name)"
//     guard let result = try actual.evaluate() else {
//       return false
//     }
//
//     switch result {
//     case let .success(font):
//       return font.name == name
//     case .failure:
//       return false
//     }
//   }
// }

// input=font=Monaco
// parser<Font>: font-parser
// result=W<Font>
//         expect(input("font=Monaco", with: parser)).to(output("Monaco"))

func input<T: Paramable>(_ input: String, with parser: P<T>) -> W<String> {
  switch Pro.parse(parser, input) {
  case let Result.success(result, _):
    return .success(result.raw)
  case Result.failure(_):
    return .failure
  }
}

// Just an alias for equal()
// cmp=Monaco
// W(Param<String>)
func output<T: Equatable>(_ cmp: T) -> MatcherFunc<W<T>> {
  return MatcherFunc { actual, failure in
    guard let result = try actual.evaluate() else {
      return false
    }

    switch result {
    case let .success(param):
      return param == cmp
    default:
      return false
    }
  }
}

func equal(_ name: String) -> MatcherFunc<Color> {
  return MatcherFunc { actual, failure in
    guard let color = try actual.evaluate() else {
      return false
    }

    if let other = Color(name: name) {
      return other == color
    }

    if let other = Color(hex: name) {
      return other == color
    }

    return false
  }
}

// func output<T>(url: String) -> MatcherFunc<W<URL>> {
//   return MatcherFunc { actual, failure in
//     guard let result = try actual.evaluate() else {
//       return false
//     }
//
//     switch result {
//     case let .success(url):
//       return url.absoluteS
//     default:
//       return false
//     }
//   }
// }

public func beAFailure(with exp: String) -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "exit with status != 0 and output '\(exp)'"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch result {
    case let .failure(.exit(stderr, status)) where stderr == exp && status != 0:
      return true
    default:
      failureMessage.postfixActual = String(describing: result)
      return false
    }
  }
}

public func beACrash(with exp: String) -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "crash with partial output '\(exp)'"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch result {
    case let .failure(.crash(message)) where message.contains(exp):
      return true
    default:
      failureMessage.postfixActual = String(describing: result)
      return false
    }
  }
}

public func have(environment: String, setTo value: String) -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "environment \(environment) set to \(value)"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch result {
    case let .success(stdout, 0):
      return stdout == value + "\n"
    default:
      failureMessage.postfixActual = String(describing: result)
      return false
    }
  }
}

func toFile(_ path: String) -> String {
  let res = path.components(separatedBy: ".")
  if let out = Bundle(for: Helper.self).path(forResource: res[0], ofType: res[1]) {
    return out
  }

  // FIXME
  return ""
}

public func beTerminated() -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "terminated"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch result {
    case .failure(.terminated()):
      return true
    default:
      failureMessage.postfixActual = String(describing: result)
      return false
    }
  }
}

public func beAMisuse(with exp: String) -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "misuse with partial output '\(exp)'"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch result {
    case let .failure(.misuse(message)) where message.contains(exp):
      return true
    default:
      failureMessage.postfixActual = String(describing: result)
      return false
    }
  }
}

protocol Base: class, Arbitrary, Equatable {
  func getInput() -> String
}

protocol ParamBase: Base, Equatable, Paramable {
}

extension Paramable {
}

extension File: Equatable {
  public static func == (_ a: File, _ b: File) -> Bool {
    return a.name == b.name && a.interval == b.interval && a.ext == b.ext
  }
}

extension ParamBase {
  func getInput() -> String {
    return output
  }

  // func test<T: ParamBase>(_ me: T) -> Property {
  //   return (self == me) <?> "ok"
  // }
}


// protocol Paramable: Param, Equatable, Base {
//   var value: String { get }
//   var attribute: String { get }
//   var key: String { get }
// }

// extension Param {
//   var attribute: String {
//     return key.camelCase
//   }
//
//   var input: String {
//     if self is NamedParam {
//       return (self as! NamedParam).string
//     }
//     return attribute + "=" + value
//   }
//
//   func getInput() -> String {
//     return input
//   }
// }

extension Gen {
  public func proliferateRange(_ min: Int, _ max: Int) -> Gen<[A]> {
    return Gen.choose((min, max)).flatMap(self.proliferate(withSize:))
  }
}

// TODO: Rename String.inspected()

extension Menuable {
  var body: String {
    return escape(title: headline.string) + pstr + "\n" + menus.map { $0.getInput() }.joined() + "\n"
  }

  var pstr: String {
    if params.isEmpty { return "" }
    return "| " + params.map { param in param.output }.joined(separator: " ")
  }

  func equals(_ other: Menuable) -> Bool {
    if other.headline != headline {
      return fail("Titles arnt matching", other.headline.string, headline.string)
    }

    if other.menus.count != menus.count {
      return fail("Sub menu count differs", other, self)
    }

    for (index, menu) in menus.enumerated() {
      if !menu.equals(other.menus[index]) {
        return fail("Menus are not equal")
      }
    }

    if other.level != level {
      return fail("Incorrect level", other.level, level)
    }

    for (index, param) in params.enumerated() {
      if param.output != other.params[index].output {
        return fail("Params are not equal", param, other.params[index])
      }
    }

    return true
  }

  private func fail(_ any: Any...) -> Bool {
    puts(any)
    return false
  }
}

func verify<T: Menuable & Base>(name: String, parser: P<T>, gen: Gen<T>) {
  property(name) <- forAll(gen) { item in
    let input = item.getInput()
    switch Pro.parse(parser, input) {
    case let Result.success(result, _):
      // print(input)
      // print(result)
      return (item.equals(result)) <?> "OK"
      // return (true <?> "OK")
      // TODO
//      return item.test(result).whenFail {
//        print("warning: ------------------------------------")
//        print("warning: Failed verifying \(name)")
//        print("warning: From input: ", String(describing: result))
//        print("warning: Got: ", String(describing: item))
//
//      }
    case let Result.failure(lines):
      return (false <?> "Parser failed").whenFail {
        print("warning: ------------------------------------")
        print("warning: Could not parse: ", input.inspected())
        print("warning: Failed parsing \(name)")
        for error in lines {
          print("warning:", error.inspected())
        }
      }
    }
  }
}

func verify<T: Paramable & Base>(name: String, parser: P<T>, gen: Gen<T>) {
  property(name) <- forAll(gen) { item in
    let input = item.getInput()
    switch Pro.parse(parser, input) {
    case let Result.success(result, _):
      // print(input)
      // print(result)
      return (item == result) <?> "OK"
      // return (true <?> "OK")
      // TODO
      //      return item.test(result).whenFail {
      //        print("warning: ------------------------------------")
      //        print("warning: Failed verifying \(name)")
      //        print("warning: From input: ", String(describing: result))
      //        print("warning: Got: ", String(describing: item))
      //
    //      }
    case let Result.failure(lines):
      return (false <?> "Parser failed").whenFail {
        print("warning: ------------------------------------")
        print("warning: Could not parse: ", input.inspected())
        print("warning: Failed parsing \(name)")
        for error in lines {
          print("warning:", error.inspected())
        }
      }
    }
  }
}

class Helper: QuickSpec {
 public func verify<T>(_ parser: P<T>, _ input: String, block: (T) -> Void) {
   switch Pro.parse(parser, input) {
   case let Result.success(result, _):
     block(result)
   case let Result.failure(lines):
     print("warning: Failed parsing")
     print("warning: Could not parse: ", input.inspected())
     for error in lines {
       print("warning:", error.inspected())
     }
     fail("Could not parse: " + input)
   }
 }

  public func match<T>(_ parser: P<T>, _ value: String, _ block: @escaping (T) -> Void) {
    verify(parser, value, block: block)
  }

  public func test<T>(_ parser: P<T>, _ value: String, _ block: @escaping (T) -> Void) {
    verify(parser, value, block: block)
  }

  public func failure<T>(_ parser: P<T>, _ input: String) {
    switch Pro.parse(parser, input) {
    case let Result.success(result, remain):
      fail("Expected failure, got success: \(result) with remain: \(inspect(remain))")
    case Result.failure(_):
      // TODO: Implement custom matcher
      expect(1).to(equal(1))
    }
  }
}
