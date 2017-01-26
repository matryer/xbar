import SwiftCheck
@testable import BitBar

extension Menu: Base, Val {
  private static let which: Gen<Int> = Gen<Int>.fromElements(in: 0...2)
  public var values: [String: Any] {
    return ["title": title, "submenus": menus, "container": container]
  }
  override public var description: String {
    // TODO: Clean up
    var res = ""
    for (key, value) in values {
      res += key + "=" + String(describing: value) + " "
    }

    return "<\(key): \(res)>"
  }

  func getInput() -> String {
    switch level {
    case 0:
       return "\n---\n" + body
    default:
      return "\n" + times(level, "--") + body
    }
  }

  func test(_ menu: Menu) -> Property {
    return equals(menu) ^&&^ testLevel()
  }

  func equals(_ other: Menu) -> Bool {
    if other.getTitle() != getTitle() {
      return fail("Titles arnt matching", other.getTitle(), getTitle())
    }

    if other.menus.count != menus.count {
      return fail("Sub menu count differs")
    }

    for (index, menu) in menus.enumerated() {
      if !menu.equals(other.menus[index]) {
        return fail("Menus are not equal")
      }
    }

    if other.level != level {
      return fail("Incorrect level", other.level, level)
    }

    return container == other.container
  }

  public static var arbitrary: Gen<Menu> {
    return Gen.compose { gen in
      return Menu(
        gen.generate(using: aSentence()),
        container: gen.generate(),
        menus: gen.generate(using: submenu.proliferateRange(0, 2))
      )
    }
  }

  internal static var submenu: Gen<Menu> {
    return getSubMenu(1)
  }

  internal static func getSubMenu(_ level: Int) -> Gen<Menu> {
    return Gen.compose { gen in
      return Menu(
        gen.generate(using: aSentence()),
        container: gen.generate(),
        menus: gen.generate(using: subMenusFrom(level: level)),
        level: level
      )
    }
  }

  private var body: String {
    return title + container.getInput() +
      menus.map { $0.getInput() }.joined(separator: "")
  }

  // Repeat @string @number times
  // I.e times(3, "Y") => YYY
  private func times(_ number: Int, _ string: String) -> String {
    return (0..<number).reduce("") { (acc: String, _) in acc + string }
  }

  // Generate submenu for a particular level
  private static func subMenusFrom(level: Int) -> Gen<[Menu]> {
    let collection = getSubMenu(level + 1)
    if level == 2 {
      return collection.proliferateRange(0, 0)
    }

    return collection.proliferateRange(0, 2)
  }

  private func testLevel() -> Property {
    return menus.reduce(true <?> "level") {
      $1.level - 1 ==== level ^&&^ $1.testLevel()
    }
  }

  private func fail(_ any: Any...) -> Bool {
    puts(any)
    return false
  }
}
