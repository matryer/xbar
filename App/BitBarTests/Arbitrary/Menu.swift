import SwiftCheck
@testable import BitBar

extension Menu: Base {
  static let which: Gen<Int> = Gen<Int>.fromElements(in: 0...2)

  func getInput() -> String {
    switch level {
    case 0:
       return "\n---\n" + getBody()
    default:
      return "\n" + times(level, "--") + getBody()
    }
  }

  public static var arbitrary: Gen<Menu> {
    return Gen.compose { gen in
      var params: [Param] = []
      params.append((gen.generate(using: Alternate.arbitrary)) as Param)
      params.append((gen.generate(using: Ansi.arbitrary)) as Param)
      params.append((gen.generate(using: Bash.arbitrary)) as Param)
      params.append((gen.generate(using: Color.arbitrary)) as Param)
      params.append((gen.generate(using: Dropdown.arbitrary)) as Param)
      params.append((gen.generate(using: Emojize.arbitrary)) as Param)
      params.append((gen.generate(using: Font.arbitrary)) as Param)
      params.append((gen.generate(using: Href.arbitrary)) as Param)
      params.append((gen.generate(using: Image.arbitrary)) as Param)
      params.append((gen.generate(using: Length.arbitrary)) as Param)
      params.append((gen.generate(using: Refresh.arbitrary)) as Param)
      params.append((gen.generate(using: Size.arbitrary)) as Param)
      params.append((gen.generate(using: TemplateImage.arbitrary)) as Param)
      params.append((gen.generate(using: Terminal.arbitrary)) as Param)
      params.append((gen.generate(using: Trim.arbitrary)) as Param)

      // TODO: Change to 0
      for named in gen.generate(using: NamedParam.arbitrary.proliferateRange(1, 10)) {
        params.append(named as Param)
      }

      return Menu(
        gen.generate(using: aSentence()),
        params: gen.generate(using: Gen<[Param]>.fromShufflingElements(of: params)),
        menus: gen.generate(using: Menu.submenu.proliferateRange(0, 2))
      )
    }
  }

  public static var submenu: Gen<Menu> {
    return getSubMenu(1)
  }

  public static func getSubMenu(_ level: Int) -> Gen<Menu> {
    return Gen.compose { gen in
      return Menu(
        gen.generate(using: aSentence()),
        level: level,
        menus: gen.generate(using: subMenusFrom(level: level))
      )
    }
  }

  func test(_ title: Title) -> Property {
    return title.menus.reduce(false <?> "test title.menus") {
      return ($0 ^||^ test($1)) ^&&^ $1.testLevel()
    } ^&&^ testLevel()
  }

  func test(_ menu: Menu) -> Property {
    return eq(menu) ^&&^ menu.level ==== level ^&&^ testLevel()
  }

  func testLevel() -> Property {
    return menus.reduce(true <?> "level") {
      $1.level - 1 ==== level ^&&^ $1.testLevel()
    }
  }

  func puts(_ bool: Bool, _: String) -> Bool {
    // print("error: menu.", message)
    return bool
  }

  // TODO: Impl. as static func ==
  private func eq(_ other: Menu) -> Bool {
    if other.title != title {
      return puts(false, "title")
    }

    if other.menus.count != menus.count {
      return puts(false, "menus.count")
    }

    for (index, menu) in menus.enumerated() {
      if !menu.eq(other.menus[index]) {
        return puts(false, "menus.eq(other)")
      }
    }

    if other.params.count != params.count {
      return puts(false, "params.count")
    }

    if other._params.count != _params.count {
      return puts(false, "_params.count")
    }

    for (index, param) in params.enumerated() {
      if param.toString() != other.params[index].toString() {
        return puts(false, "param.toString()")
      }
    }

    for (index, param) in _params.enumerated() {
      if param.toString() != other._params[index].toString() {
        return puts(false, "param.toString()")
      }
    }

    return true
  }

  private func getBody() -> String {
    var out = ""
    out += _params.reduce("") { $0 + " " + $1.getInput() }
    out += params.reduce("") { $0 + " " + $1.getInput() }
    out = out.noMore()

    let mOut = menus.reduce("") { $0 + $1.getInput() }
    if !out.isEmpty {
      return toString() + "|" + out + mOut
    } else {
      return toString() + mOut
    }
  }

  private func times(_ number: Int, _ string: String) -> String {
    return (0..<number).reduce("") { (acc: String, _) in acc + string }
  }

  private static func subMenusFrom(level: Int) -> Gen<[Menu]> {
    let collection = getSubMenu(level + 1)
    if level == 2 {
      return collection.proliferateRange(0, 0)
    }

    return collection.proliferateRange(0, 2)
  }
}
