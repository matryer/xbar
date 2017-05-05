import Quick
import Nimble
@testable import BitBar

extension Script {
  enum Result {
    case success(Success)
    case failure(Failure)
  }
}

func equal(_ value: String) -> MatcherFunc<Value> {
  return MatcherFunc { actual, _ in
    guard let result = try actual.evaluate() else {
      return false
    }

    switch result {
    case let (other, _):
      return other == value
    }
  }
}

// expect("ABC".bold).to(beItalic())
func beItalic() -> MatcherFunc<Value> {
  return test(expect: .italic(true), label: "italic")
}

// expect("ABC".bold).to(beBold())
func beBold() -> MatcherFunc<Value> {
  return test(expect: .bold(true), label: "bold")
}

// expect("ABC").to(have(color: 10))
func have(color actual: Int) -> MatcherFunc<Value> {
  return test(expect: .color(.foreground, .index(actual)), label: "256 color")
}

// expect("ABC").to(have(background: 10))
func have(background actual: Int) -> MatcherFunc<Value> {
  return test(expect: .color(.background, .index(actual)), label: "256 background color")
}

// expect("ABC").to(have(background: [10, 20, 30]))
func have(background colors: [Int]) -> MatcherFunc<Value> {
  if colors.count != 3 { preconditionFailure("Rgb must contain 3 ints") }
  let expect: Code = .color(.background, .rgb(colors[0], colors[1], colors[2]))
  return test(expect: expect, label: "RGB background color")
}

// expect("ABC").to(have(rgb: [10, 20, 30]))
func have(rgb colors: [Int]) -> MatcherFunc<Value> {
  if colors.count != 3 { preconditionFailure("Rgb must contain 3 ints") }
  let expect: Code = .color(.foreground, .rgb(colors[0], colors[1], colors[2]))
  return test(expect: expect, label: "RGB foreground color")
}

// expect("ABC").to(haveNoStyle())
func haveNoStyle() -> MatcherFunc<Value> {
  return tester("no style") { (_, codes) in
    return codes.isEmpty
  }
}

// expect("ABC".blink).to(blink())
func blink(_ speed: Speed) -> MatcherFunc<Value> {
  return test(expect: .blink(speed), label: "blink")
}

// expect("ABC").to(haveUnderline())
func haveUnderline() -> MatcherFunc<Value> {
  return test(expect: .underline(true), label: "underline")
}

// expect("ABC".red).to(be(.red))
func be(_ color: CColor) -> MatcherFunc<Value> {
  return test(expect: .color(.foreground, color), label: "color")
}

// expect("ABC".background(color: .red)).to(have(background: .red))
func have(background color: CColor) -> MatcherFunc<Value> {
  return test(expect: .color(.background, color), label: "color")
}

func beASuccess(with exp: String? = nil) -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "exit with status 0 and output '\(exp ?? "")'"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch (result, exp) {
    case (.success, .none):
      return true
    case let (.success(success), .some(exp)) where success.output == exp:
      return true
    default:
      failureMessage.postfixActual = String(describing: result)
      return false
    }
  }
}

// Just an alias for equal()
// cmp=Monaco
// W(Param<String>)
func output<T: Equatable>(_ cmp: T) -> MatcherFunc<W<T>> {
  return MatcherFunc { actual, _ in
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

func beAFailure(with exp: String) -> MatcherFunc<Script.Result> {
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

func beACrash(with exp: String) -> MatcherFunc<Script.Result> {
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

func have(environment: String, setTo value: String) -> MatcherFunc<Script.Result> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "environment \(environment) set to \(value)"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch result {
    case let .success(success):
      return success.output == value + "\n"
    default:
      failureMessage.postfixActual = String(describing: result)
      return false
    }
  }
}

func beTerminated() -> MatcherFunc<Script.Result> { return MatcherFunc { actualExpression, failureMessage in
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

func beAMisuse(with exp: String) -> MatcherFunc<Script.Result> {
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
