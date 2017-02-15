import SwiftCheck
import Quick
import Swift
import Nimble
@testable import BitBar

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

func toFile(_ path: String) -> String {
  return Bundle(for: ScriptTests.self).resourcePath! + "/" + path
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

protocol Base: Arbitrary {
  func getInput() -> String
  func test(_ me: Self) -> Property
}

extension Base {
}

protocol Paramable: Param, Equatable, Base {
  var value: String { get }
  var attribute: String { get }
  var key: String { get }
}

extension Param {
  var attribute: String {
    return key.camelCase
  }

  var input: String {
    if self is NamedParam {
      return (self as! NamedParam).string
    }
    return attribute + "=" + value
  }

  func getInput() -> String {
    return input
  }
}

extension Gen {
  public func proliferateRange(_ min: Int, _ max: Int) -> Gen<[A]> {
    return Gen.choose((min, max)).flatMap(self.proliferate(withSize:))
  }
}

// TODO: Rename String.inspected()

func verify<T: Base>(name: String, parser: P<T>, gen: Gen<T>) {
  property(name) <- forAll(gen) { item in
    let input = item.getInput()
    switch Pro.parse(parser, input) {
    case let Result.success(result, _):
      return item.test(result).whenFail {
        print("warning: ------------------------------------")
        print("warning: Failed verifying \(name)")
        print("warning: From input: ", String(describing: result))
        print("warning: Got: ", String(describing: item))

      }
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
  public func verify<T>(_ parser: P<T>, _ input: String, _ block: (_: T, _: String) -> Void) {
    switch Pro.parse(parser, input) {
    case let Result.success(result, remain):
      block(result, remain)
    case let Result.failure(lines):
      print("warning: Failed parsing")
      print("warning: Could not parse: ", input.inspected())
      for error in lines {
        print("warning:", error.inspected())
      }
      fail("Could not parse")
    }
  }

  public func match<T>(_ parser: P<T>, _ value: String, _ block: (_: T, _: String) -> Void) {
    verify(parser, value, block)
  }

  public func match<T>(_ parser: P<T>, _ value: String, _ block: @escaping (_: T) -> Void) {
    verify(parser, value) { result, _ in block(result) }
  }

  public func test<T>(_ parser: P<T>, _ value: String, _ block: @escaping (_: T) -> Void) {
    verify(parser, value) { result, _ in block(result) }
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
