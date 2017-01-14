import SwiftCheck
import Quick
import Cent
import Nimble
@testable import BitBar

let failed = false <?> "Parser failed"
let upper: Gen<Character>= Gen<Character>.fromElements(in: "A"..."Z")
let lower: Gen<Character> = Gen<Character>.fromElements(in: "a"..."z")
let natrual = Int.arbitrary.suchThat { $0 >= 0 }
let numeric: Gen<Character> = Gen<Character>.fromElements(in: "0"..."9")
let upperAF: Gen<Character>= Gen<Character>.fromElements(in: "A"..."F")
let loweraf: Gen<Character> = Gen<Character>.fromElements(in: "a"..."f")
let hexValue = Gen<Int>.choose((1, 6)).flatMap {
  return toString(upperAF, loweraf, numeric, size: $0)
}
let special: Gen<Character> = Gen<Character>.fromElements(of:
    ["!", "#", "$", "%", "&", "'", "*", "+", "-", "/",
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

func aWord() -> Gen<String> {
  return char.proliferateRange(1, 10).map { String.init($0) }
  // TODO: Use
  // return Character.arbitrary.proliferateNonEmpty.map { String.init($0) }.suchThat { $0.noMore() != "" }
}

func aSentence() -> Gen<String> {
  let whitespace = anyOf("", "\t")
  return Gen<(String, String, String)>
    .zip(whitespace, aWord(), whitespace)
    .map { $0 + $1 + $2 }
    .proliferate
    .map { $0.joined(separator: "")
  }
}

protocol Base: Arbitrary {
  func getInput() -> String
  func test(_ me: Self) -> Property
}

extension Base {
  public var description: String {
    return "<\(type(of: self))>"
  }
}

protocol Paramable: Param, Base {
  var attribute: String { get }
  func toString() -> String
}

extension Param {
  public var description: String {
    return "<\(type(of: self))>"
  }

  func getInput() -> String {
    if self is NamedParam {
      return toString()
    }
    return "\(type(of: self))".camelCase + "=" + toString()
  }
}

extension Gen {
  public func proliferateRange(_ min: Int, _ max: Int) -> Gen<[A]> {
    return Gen.choose((min, max)).flatMap(self.proliferate(withSize:))
  }
}

// TODO: This needs a clean up
func verify<T: Base>(name: String, parser: P<T>, gen: Gen<T>) {
  property(name) <- forAll(gen) { item in
    switch Pro.parse(parser, item.getInput()) {
    case let Result.success(result, _):
      return item.test(result).whenFail {
        print("error: ", "[2] ------------------------------------")
        print("error: input ", inspect(item.getInput()))
        print("error: ", "in: ", name)
        print("error: result", result)
      }
    case let Result.failure(lines):
      return (false <?> "X").whenFail {
        print("error: ", "START ------------------------------------")
        print("error: input ", inspect(item.getInput()))
        print("error: ", "in: ", name)
        for line in lines {
          print("error: ", inspect(line))
        }
        print("error: ", "------------------------------------ END")
      }
    }
  }
}

class Helper: QuickSpec {
  public func verify<T>(_ parser: P<T>, _ input: String, _ block: (_: T, _: String) -> Void) {
    switch Pro.parse(parser, input) {
    case let Result.success(result, remain):
      block(result, remain)
    case let Result.failure(error):
      fail("Could not parse: '\(input.replace("\n", "\\n"))', got error: \(error)")
    }
  }

  public func match<T>(_ parser: P<T>, _ value: String, _ block: (_: T, _: String) -> Void) {
    verify(parser, value, block)
  }

  public func match<T>(_ parser: P<T>, _ value: String, _ block: @escaping (_: T) -> Void) {
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
