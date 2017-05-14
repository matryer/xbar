import Quick
import Ansi
import Files
import Cent
import Parser
import Nimble
import Async
@testable import BitBar

var noShortcut: TestValue { return .noShortcut }
var noSubMenus: TestValue { return .noSubMenus }

func item (block: @escaping (Menuable) -> Void) {
  let mock = MockParent()
  let plugin = PluginFile(
    file: try! Files.File(path: aFile),
    delegate: mock
  )

  waitUntil(timeout: 10) { done in
    Async.background {
      repeat {
        Thread.sleep(forTimeInterval: 0.3)
      }  while !plugin.hasLoaded
    }.main {
      block(plugin)
      done()
    }
  }
}

func a(_ aMenu: Menuable, at indexes: [Int] = [], block: @escaping (Menuable) -> Void) {
  block(menu(aMenu, at: indexes))
}

func menu(_ menu: Menuable, at indexes: [Int] = []) -> Menuable {
  return try! menu.get(at: indexes)
}

func have(args: [String]) -> Predicate<Menuable> {
  return verify("have args \(args)") { menu in
    return .bool(menu.args == args, args)
  }
}

func have(environment env: String, setTo value: String) -> Predicate<Script.Result> {
  /* TODO: Compare against env */
  return verify("environment \(env) set to \(value)") { result in
    switch result {
    case let .success(result):
      return .bool(result.output == value + "\n", result)
    default:
      return .fail(result)
    }
  }
}

func beTerminated() -> Predicate<Script.Result> {
  return verify("be terminated") { result in
    switch result {
    case .failure(.terminated()):
      return .bool(true, result)
    default:
      return .bool(false, result)
    }
  }
}

func beAMisuse(with exp: String) -> Predicate<Script.Result> {
  return verify("be misused with \(exp)") { result in
    switch result {
    case let .failure(.misuse(message)) where message.contains(exp):
      return .bool(message.contains(exp), message)
    default:
      return .fail(result)
    }
  }
}

func have(foreground color: Ansi.Color) -> Predicate<Menuable> {
  return verify("have foreground color \(color)") { menu in
    return .bool(menu.banner.has(foreground: color.toNSColor()), "a color")
  }
}

func toImage(string: String, isTemplate: Bool) -> NSImage? {
  guard let data = Data(base64Encoded: string) else {
    return nil
  }

  return NSImage(data: data, isTemplate: isTemplate)
}

func have(imageUrl: String, isTemplate: Bool) -> Predicate<Menuable> {
  return verify("have an image from url \(imageUrl)") { menu in
    guard let image1 = menu.image else {
      return .fail("no image")
    }

    guard let url = URL(string: imageUrl) else {
      return .fail("an invalid url")
    }

    var data: Data!
    do {
      data = try Data(contentsOf: url)
    } catch(let error) {
      return .fail("a broken due to \(error)")
    }

    guard let image2 = NSImage(data: data, isTemplate: isTemplate) else {
      return .fail("invalid data")
    }

    guard image1.size == image2.size else {
      return .fail("size missmatch")
    }

    if isTemplate {
      return .bool(image1.isTemplate, "an image")
    }

    return .bool(!image1.isTemplate, "an image")
  }
}

func have(image: String, isTemplate: Bool) -> Predicate<Menuable> {
  return verify("have an image from base64") { menu in
    guard let image1 = menu.image else {
      return .fail("invalid data")
    }

    guard let image2 = toImage(string: image, isTemplate: isTemplate) else {
      return .fail("non parseable image")
    }

    guard image1.size == image2.size else {
      return .fail("size missmatch")
    }

    if isTemplate {
      return .bool(image1.isTemplate, "an image")
    }

    return .bool(!image1.isTemplate, "an image")
  }
}

func contain(title: String) -> Predicate<Menuable> {
  return verify("have title \(title)") { menu in
    return .bool(menu.banner.string.contains(title), menu.banner.string)
  }
}

func have(title: String) -> Predicate<Menuable> {
  return verify("have title \(title)") { menu in
    return .bool(title == menu.banner.string, menu.banner.string)
  }
}

func have(title: Immutable) -> Predicate<Menuable> {
  return verify("have mutable title \(title.string)") { menu in
    /* TODO Test Menuable properly */
    return .bool(title.string == menu.banner.string, menu.banner)
  }
}

func have(font: String?) -> Predicate<Menuable> {
  return verify("have font \(String(describing: font))") { menu in
    return .bool(font == menu.banner.fontName, menu.banner.fontName ?? "no font")
  }
}

func have(background color: Ansi.Color) -> Predicate<Menuable> {
  return verify("have background color \(color)") { menu in
    return .bool(menu.banner.has(background: color.toNSColor()), "unknown")
  }
}

func have(size: Int) -> Predicate<Menuable> {
  return verify("font size \(size)") { menu in
    return .bool(size == menu.banner.fontSize, menu.banner.fontSize ?? "no size")
  }
}

func beClickable() -> Predicate<Menuable> {
  return verify("be clickable") { menu in
    return .bool(menu.isClickable, menu.isClickable ? "clickable" : "not clickable")
  }
}

func have(subMenuCount count: Int) -> Predicate<Menuable> {
  return verify("submenu count \(count)") { menu in
    return .bool(count == menu.menus.count, menu.menus.count)
  }
}

func have(shortcut: String) -> Predicate<Menuable> {
  return verify("shortcut \(shortcut)") { menu in
    return .bool(shortcut == menu.keyEquivalent, menu.keyEquivalent)
  }
}

func have(_ value: TestValue)-> Predicate<Menuable> {
  switch value {
  case .noShortcut:
    return have(shortcut: "")
  case .noSubMenus:
    return have(subMenuCount: 0)
  case let .broadcasted(events):
    return have(events: events)
  case .noFont:
    return have(font: nil)
  }
}

func haveNoSubMenus() -> Predicate<Menuable> {
  return have(subMenuCount: 0)
}

func beAlternatable() -> Predicate<Menuable> {
  return verify("alternate") { menu in
    return .bool(
      menu.isAlternate,
      menu.isAlternate ? "an alternating menu" : "a non alternating menu"
    )
  }
}

func beASeparator() -> Predicate<Menuable> {
  return verify("be a separator") { menu in
    return .bool(
      menu.isSeparator,
      menu.isSeparator ? "a separator item" : "a non separator item"
    )
  }
}

func beChecked() -> Predicate<Menuable> {
  return verify("be checked") { menu in
    return .bool(
      menu.isChecked,
      menu.isChecked ? "a checked menu" : "a unchecked menu"
    )
  }
}

func beTrimmed() -> Predicate<Menuable> {
  return verify("be trimmed") { menu in
    return .bool(menu.banner.string.trimmed() == menu.banner.string, "unknown")
  }
}

func expect(_ menu: Menuable, when: ClickEvent) -> Expectation<Menuable> {
  switch when {
  case .clicked:
    menu.set(parent: MockParent())
    menu.onDidClick()
    return expect(menu)
  }
}

func have(events: [MenuEvent]) -> Predicate<Menuable> {
  return verify("have events \(events)") { menu in
    if !menu.isEnabled && !events.isEmpty {
      return .fail("an unclickable menu")
    }
    return .bool(events.sorted() == menu.events.sorted(), menu.events)
  }
}

func receive(_ events: [MenuEvent], from indexes: [Int]) -> Predicate<Menuable> {
  let mock = MockParent()
  var clicked = false
  return verify("receive events \(events)") { parent in
    if !parent.isEnabled && !events.isEmpty {
      return .fail("an unclickable menu")
    }

    let child = menu(parent, at: indexes)
    if !clicked {
      parent.set(parent: mock)
      child.onDidClick()
      clicked = true
    }
    return .bool(events.sorted() == parent.events.sorted(), parent.events)
  }
}

func verify<T>(_ message: String, block: @escaping (T) -> State) -> Predicate<T> {
  return Predicate.define { actualExpression in
    guard let result = try actualExpression.evaluate() else {
      return PredicateResult(
        status: .fail,
        message: .expectedCustomValueTo(message, "nothing")
      )
    }

    switch block(result) {
    case let .bool(status, actual):
      return PredicateResult(
        bool: status,
        message: .expectedCustomValueTo(message, String(describing: actual))
      )
    case let .fail(actual):
      return PredicateResult(
        status: .fail,
        message: .expectedCustomValueTo(message, String(describing: actual))
      )
    case let .lift(result):
      return result
    }
  }
}

func have(href: String) -> Predicate<Menuable> {
  return verify("have href \(href)") { menu in
    switch menu.act {
    case let .href(actual, _):
      return .bool(href == actual, actual)
    default:
      return .fail(menu.act)
    }
  }
}

func execute(path: String, args: [String] = [], autostart: Bool = true) -> (FakeScriptable, Script) {
  let delegate = FakeScriptable()
  var realPath = path
  if path != "does-not-exist.sh" {
    realPath = toFile(path)
  }

  let script = Script(path: realPath, args: args, delegate: delegate, autostart: autostart)
  return (delegate, script)
}


func crash(with message: String) -> Predicate<String> {
  return result(in: .fail(.crash(message)), message: "crash with \(message.inspected())")
}

func crash(misuse message: String) -> Predicate<String> {
  return result(in: .fail(.misuse(message)), message: "fail as misuse with \(message.inspected())")
}

func toSucc(_ output: String) -> Std {
  return .succ(Script.Success(status: 0, output: output))
}

// expect(script).toEventually(succeed(with: "output"))
func succeed(with message: String) -> Predicate<String> {
  return succeed(with: [message])
}

// expect(script).toEventually(succeed(with: ["output"]))
func succeed(with messages: [String]) -> Predicate<String> {
  return lift(succeed(with: messages)) { path in (path, [String]()) }
}

func succeed(with message: String) -> Predicate<(String, [String])> {
  return that(in: [toSucc(message)], message: message)
}

func succeed(with messages: [String]) -> Predicate<(String, [String])> {
  return that(in: messages.map(toSucc), message: "succeed with outputs \(messages)")
}

// expect(script).toEventually(exit(message: "output", andStatusCode: 2))
func exit(with message: String, andStatusCode status: Int) -> Predicate<String> {
  return result(
    in: .fail(.exit(message, status)),
    message: "exit with output \(message.inspected()) and status code \(status)"
  )
}

func result(in expected: Std, message: String) -> Predicate<String> {
  return lift(that(in: [expected], message: message)) { path in (path, []) }
}

func that(in expected: [Std], message: String) -> Predicate<(String, [String])> {
  return lift(that2(in: expected, message: message)) { param in
    let (path, args) = param
    return (path, args, true)
  }
}

// TODO: Rename
func that2(in expected: [Std], message: String) -> Predicate<(String, [String], Bool)> {
  if expected.isEmpty { preconditionFailure("Arg can't be empty") }

  var delegate: FakeScriptable!
  var script: Script!
  var hasInit = false

  return verify(message) { params in
    let (path, args, autostart) = params
    if !hasInit {
      let (d, s)  = execute(path: path, args: args, autostart: autostart)
      delegate = d
      script = s
      hasInit = true
    }

    let result = delegate.result
    let res = result.enumerated().reduce(true) { acc, state in
      let (index, status) = state
      switch expected.get(index: index) {
      case let .some(exp):
        return exp == status
      case .none:
        return acc
      }
    }

    if res && result.count == expected.count {
      script.stop()
      return .bool(true, result)
    }

    return .bool(false, result)
  }
}

func lift<T, U>(_ that: Predicate<U>, block: @escaping (T) -> U) -> Predicate<T> {
  return Predicate.define { exp in
    return try that.satisfies(exp.cast { maybe in
      if let val = maybe {
        return block(val)
      }

      return nil
    })
  }
}
