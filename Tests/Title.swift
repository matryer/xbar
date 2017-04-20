import SwiftCheck
@testable import BitBar

extension Title: Base {
  func getInput() -> String {
    return escape(title: headline.string) + pstr + getBody()
  }

  func getBody() -> String {
    if menus.isEmpty { return "\n" }
    return "\n---\n" + menus.map { $0.getInput() }.joined() + "\n" + tail
  }

  /* Randomize stream ending */
  private var tail: String {
    if menus.count % 2 == 0 { return "~~~\n"}
    return ""
  }

  public static var arbitrary: Gen<Title> {
    return Gen.compose { gen in
      return Title(
        gen.generate(),
        params: [Paramable](),
        menus: gen.generate(using: Menu.arbitrary.proliferateRange(0, 2))
      )
    }
  }
}
