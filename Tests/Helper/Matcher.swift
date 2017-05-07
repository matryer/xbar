import Quick
import Cent
import Nimble
import Attr
import Ansi
import Async
@testable import BitBar


func item(_ plugin: Plugin, at indexes: [Int] = [], block: @escaping (W<Menuable>) -> Void) {
  waitUntil(timeout: 10) { done in
    Async.background {
      repeat {
        Thread.sleep(forTimeInterval: 0.3)
      }  while plugin.title == nil
    }.main {
      block(menu(plugin.title!, at: indexes))
      done()
    }
  }
}

func a(_ aMenu: W<Menuable>, at indexes: [Int] = [], block: @escaping (W<Menuable>) -> Void) {
  switch aMenu {
  case let .success(head):
    block(menu(head, at: indexes))
  case .failure:
    block(.failure)
  }
}

func menu(_ menu: Menuable, at indexes: [Int] = []) -> W<Menuable> {
  do {
    return .success(try menu.get(at: indexes))
  } catch {
    return .failure
  }
}

func the<T: Menuable>(_ parser: P<T>, with input: String) -> W<String> {
  switch Pro.parse(parser, input) {
  case let Result.success(result, _):
    return .success(result.banner.string)
  case Result.failure(_):
    return .failure
  }
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

func have(args: [String]) -> MatcherFunc<W<Menuable>> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "args \(args.joined(separator: ", "))"
    guard let result = try actualExpression.evaluate() else {
      return false
    }

    switch result {
    case let .success(menu):
      return menu.args == args
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

func have(foreground color: Ansi.Color) -> MatcherFunc<W<Menuable>> {
  return tester("have a foreground") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.banner.has(foreground: color.toNSColor())
    case .failure:
      return "expected a color much like \(color)"
    }
  }
}

func toImage(string: String, isTemplate: Bool) -> NSImage? {
  guard let data = Data(base64Encoded: string) else {
    return nil
  }

  return NSImage(data: data, isTemplate: isTemplate)
}

func have(imageUrl: String, isTemplate: Bool) -> MatcherFunc<W<Menuable>> {
  return tester("have an image") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      guard let image1 = menu.image else {
        return "menu could not parse image"
      }

      guard let url = URL(string: imageUrl) else {
        return "could not get image url from \(imageUrl)"
      }

      var data: Data!
      do {
        data = try Data(contentsOf: url)
      } catch(let error) {
        return "could not download image url: \(error)"
      }

      guard let image2 = NSImage(data: data, isTemplate: isTemplate) else {
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

func have(image: String, isTemplate: Bool) -> MatcherFunc<W<Menuable>> {
  return tester("have an image") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      guard let image1 = menu.image else {
        return "menu could not parse image"
      }

      guard let image2 = toImage(string: image, isTemplate: isTemplate) else {
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
  return t("title") { (result: W<Menuable>) -> Test<String> in
    switch result {
    case let .success(menu):
      return .comp(title, menu.banner.string)
    case .failure:
      return .fail
    }
  }
}

func contain(title: String) -> MatcherFunc<W<Menuable>> {
  return tester("have a title") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.banner.string.contains(title)
    case .failure:
      return "to have a title"
    }
  }
}

func have(title: Mutable) -> MatcherFunc<W<Menuable>> {
  return tester("have a title") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.banner.string == title.string
    case .failure:
      return "to have a title"
    }
  }
}

func have(font: String) -> MatcherFunc<W<Menuable>> {
  return t("font name") { result -> Test<String> in
    switch result {
    case let .success(menu):
      return .comp(font, menu.banner.fontName)
    case .failure:
      return .fail
    }
  }
}

func have(background color: Ansi.Color) -> MatcherFunc<W<Menuable>> {
  return tester("have a background") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.banner.has(background: color.toNSColor())
    case .failure:
      return "expected a color much like \(color)"
    }
  }
}

func have(size: Int) -> MatcherFunc<W<Menuable>> {
  return t("font size") { result -> Test<Int> in
    switch result {
    case let .success(menu):
      return .comp(size, menu.banner.fontSize)
    case .failure:
      return .fail
    }
  }
}

func beBold() -> MatcherFunc<W<Menuable>> {
  return tester("bold") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.banner.isBold
    case .failure:
      return "failed with a failure"
    }
  }
}

func beClickable() -> MatcherFunc<W<Menuable>> {
  return t("clickable") { result -> Test<Bool> in
    switch result {
    case let .success(menu):
      return .comp(true, menu.isEnabled)
    case .failure:
      return .fail
    }
  }
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

func beAlternatable() -> MatcherFunc<W<Menuable>> {
  return tester("alternate") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.isAlternate
    case .failure:
      return "failed with a failure"
    }
  }
}

func beASeparator() -> MatcherFunc<W<Menuable>> {
  return tester("separator") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.isSeparator
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
      return menu.banner.isItalic
    case .failure:
      return "failed with a failure"
    }
  }
}

func beTrimmed() -> MatcherFunc<W<Menuable>> {
  return tester("trimmed") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
    return menu.banner == menu.banner.trimmed()
    case .failure:
      return "to be trimmed"
    }
  }
}

func have(href: String) -> MatcherFunc<W<Menuable>> {
  return tester("href") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
    return menu.banner == menu.banner.trimmed()
    case .failure:
      return "to be trimmed"
    }
  }
}
