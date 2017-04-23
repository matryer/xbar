import SwiftCheck
import Attr
@testable import BitBar

extension Menu: Base {
  private static let which: Gen<Int> = (0...2).any
  func getInput() -> String {
    return times(level, "--") + body
  }

  public static var arbitrary: Gen<Menu> {
    return Gen.compose { gen in
      return Menu(
        gen.generate(),
        params: toParam(gen: gen),
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
        gen.generate(),
        params: toParam(gen: gen),
        menus: gen.generate(using: subMenusFrom(level: level)),
        level: level
      )
    }
  }

  // Repeat @string @number times
  // I.e times(3, "Y") => YYY
  private func times(_ number: Int, _ string: String) -> String {
    return (0..<number).reduce("") { (acc: String, _) in acc + string }
  }

  // Generate submenu for a particular level
  private static func subMenusFrom(level: Int) -> Gen<[Menu]> {
    if level >= 2 { return Gen.pure([Menu]()) }
    return getSubMenu(level + 1).proliferateRange(0, 1)
  }
}
