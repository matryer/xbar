import SwiftCheck
@testable import BitBar

extension Title: Base, Val {
  public var values: [String: Any] {
    return ["title": title, "menus": menus, "container": container]
  }

  // TODO: Clean up
  override public var description: String {
    var res = ""
    for (key, value) in values {
      res += key + "=" + String(describing: value) + " "
    }

    return "<\(key): \(res)>"
  }

  func getInput() -> String {
    return escape(title: title) + container.getInput() + getBody()
  }

  func getBody() -> String {
    if menus.isEmpty { return "\n" }
    return "\n---\n" + menus.map { $0.getInput() }.joined(separator: "") + "\n"
  }

  public static var arbitrary: Gen<Title> {
    return Gen.compose { gen in
      return Title(
        gen.generate(),
        container: gen.generate(),
        menus: gen.generate(using: Menu.arbitrary.proliferateRange(0, 2))
      )
    }
  }

  func test(_ title: Title) -> Property {
    return equals(title) <?> "title"
  }

  func equals(_ title: Title) -> Bool {
    if title.menus.count != menus.count {
      return false
    }

    if title.getTitle() != getTitle() {
      return false
    }

    if title.getAttrs() != getAttrs() {
      return false
    }

    for (index, menu) in menus.enumerated() {
      if !menu.equals(title.menus[index]) {
        return false
      }
    }

    return title.container == container
  }
}
