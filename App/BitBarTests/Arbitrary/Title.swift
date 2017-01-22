import SwiftCheck
@testable import BitBar

extension Title: Base {
  override public var description: String {
    return "<\(type(of: self))>"
  }

  func getInput() -> String {
    let out = params.reduce("") { $0 + " " + $1.getInput() }.noMore()
    let mOut = menus.map { $0.getInput() }.joined(separator: "")
    if !out.isEmpty {
      return title + "|" + out + mOut
    } else {
      return title + mOut
    }
  }

  // TODO: Merge with Menu
  public static var arbitrary: Gen<Title> {
    let menus = Menu.arbitrary.proliferateRange(0, 2)
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

      return Title(
        gen.generate(using: aSentence()),
        params: gen.generate(using: Gen<[Param]>.fromShufflingElements(of: params)),
        menus: gen.generate(using: menus)
      )
    }
  }

  func test(_ title: Title) -> Property {
    if title.menus.count != menus.count {
      return false <?> "Missing menus. Got \(title.menus.count), expected: \(menus.count)"
    }

    if params.count != title.params.count {
      return false <?> "params.count"
    }

    if !params.isEmpty {
      for (index, param1) in params.enumerated() {
        if !title.params.reduce(false) { acc, param2 in
          acc || (param1.toString() == param2.toString())
        } {
          return false <?> "param1 != param2"
        }
      }
    }

    return title.getValue() ==== self.getValue()
      ^&&^ menus.reduce(true) { $0 ^&&^ $1.test(title) }
  }
}
