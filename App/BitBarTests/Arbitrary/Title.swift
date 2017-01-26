import SwiftCheck
@testable import BitBar

extension Title: Base, Val {
  public var values: [String: Any] {
    return ["title": title, "menus": menus, "container": container]
  }

  override public var description: String {
    var res = ""
    for (key, value) in values {
      res += key + "=" + String(describing: value) + " "
    }

    return "<\(key): \(res)>"
  }

  func getInput() -> String {
    return title + container.getInput() +
      menus.map { $0.getInput() }.joined(separator: "")
  }

  public static var arbitrary: Gen<Title> {
    return Gen.compose { gen in
      return Title(
        gen.generate(using: aSentence()),
        container: gen.generate(),
        menus: gen.generate(using: Menu.arbitrary.proliferateRange(0, 2))
      )
    }
  }

  func test(_ title: Title) -> Property {
    if title.menus.count != menus.count {
      return false <?> "Missing menus. Got \(title.menus.count), expected: \(menus.count)"
    }

    if title.getTitle() != getTitle() {
      return false <?> "title"
    }

    for (index, menu) in menus.enumerated() {
      if !menu.equals(title.menus[index]) {
        return false <?> "menu.index.\(index)"
      }
    }

    return title.container ==== container
  }
}
