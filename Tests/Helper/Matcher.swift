import Quick
import Nimble
@testable import BitBar

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

func the<T: Menuable>(_ parser: P<T>, with input: String) -> W<String> {
  switch Pro.parse(parser, input) {
  case let Result.success(result, _):
    return .success(result.headline.string)
  case Result.failure(_):
    return .failure
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

func equal(_ name: String) -> MatcherFunc<Color> {
  return MatcherFunc { actual, _ in
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

public func beTerminated() -> MatcherFunc<Script.Result> { return MatcherFunc { actualExpression, failureMessage in
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

func have(foreground color: CColor) -> MatcherFunc<W<Menuable>> {
  return tester("have a foreground") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.headline.has(foreground: color.toNSColor())
    case .failure:
      return "expected a color much like \(color)"
    }
  }
}

func have(image: String, isTemplate: Bool) -> MatcherFunc<W<Menuable>> {
  return tester("have an image") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      guard let image1 = menu.image else {
        return "menu could not parse image"
      }

      guard let image2 = toImage(string: image) else {
        return "failed to parse image in menu"
      }

      // TODO: Compare content, not size
      guard image1.size == image2.size else {
        return false
      }

      if isTemplate {
        return image1.isTemplate
      }

      return !image1.isTemplate
    case .failure:
      return "to have an image"
    }
  }
}

func have(title: String) -> MatcherFunc<W<Menuable>> {
  return tester("have a title") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.headline.string == title
    case .failure:
      return "to have a title"
    }
  }
}

func contain(title: String) -> MatcherFunc<W<Menuable>> {
  return tester("have a title") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.headline.string.contains(title)
    case .failure:
      return "to have a title"
    }
  }
}

func have(title: Mutable) -> MatcherFunc<W<Menuable>> {
  return tester("have a title") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.headline == title
    case .failure:
      return "to have a title"
    }
  }
}

func have(font: String) -> MatcherFunc<W<Menuable>> {
  return tester("to have have font") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.headline.fontName == font
    case .failure:
      return "expected font \(font)"
    }
  }
}

func have(background color: CColor) -> MatcherFunc<W<Menuable>> {
  return tester("have a background") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.headline.has(background: color.toNSColor())
    case .failure:
      return "expected a color much like \(color)"
    }
  }
}

func have(size: Int) -> MatcherFunc<W<Menuable>> {
  return tester("to have size") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.headline.fontSize == size
    case .failure:
      return "expected a menu"
    }
  }
}

func beBold() -> MatcherFunc<W<Menuable>> {
  return tester("bold") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.headline.isBold
    case .failure:
      return "failed with a failure"
    }
  }
}

func beClickable() -> MatcherFunc<W<Menuable>> {
  return tester("clickable") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.isEnabled
    case .failure:
      return "failed with a failure"
    }
  }
}

// TODO: Replace with below
func haveSubMenuCount(_ count: Int) -> MatcherFunc<W<Menuable>> {
  return have(subMenuCount: count)
}

func have(subMenuCount count: Int) -> MatcherFunc<W<Menuable>> {
  return tester("have sub menu count of \(count)") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      if menu.menus.count == count { return true }
      return "sub menu count of \(menu.menus.count)"
    case .failure:
      return "failed to get menu"
    }
  }
}

func beAnAlternate() -> MatcherFunc<W<Menuable>> {
  return tester("alternate") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.isAltAlternate
    case .failure:
      return "failed with a failure"
    }
  }
}

func beASeparator() -> MatcherFunc<W<Menuable>> {
  return tester("separator") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.isSeparator()
    case .failure:
      return "failed with a failure"
    }
  }
}

func beChecked() -> MatcherFunc<W<Menuable>> {
  return tester("alternate") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.isChecked
    case .failure:
      return "failed with a failure"
    }
  }
}

func beItalic() -> MatcherFunc<W<Menuable>> {
  return tester("italic") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.headline.isItalic
    case .failure:
      return "failed with a failure"
    }
  }
}

func beTrimmed() -> MatcherFunc<W<Menuable>> {
  return tester("trimmed") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
    return menu.headline == menu.headline.trimmed()
    case .failure:
      return "to be trimmed"
    }
  }
}

func have(href: String) -> MatcherFunc<W<Menuable>> {
  return tester("href") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
    return menu.headline == menu.headline.trimmed()
    case .failure:
      return "to be trimmed"
    }
  }
}
