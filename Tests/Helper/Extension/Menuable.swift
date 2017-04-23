import SwiftCheck
@testable import BitBar

extension Menuable {
  var body: String {
    return escape(title: headline.string) + pstr + "\n" + menus.map { $0.getInput() }.joined() + "\n"
  }

  var pstr: String {
    if lines.isEmpty { return "" }
    return "| " + lines.map { param in param.output }.joined(separator: " ")
  }

  static func toParam(gen: GenComposer) -> [Line] {
    var params = [Line]()
    params.append(.param((gen.generate(using: Alternate.arbitrary)) as Paramable))
    params.append(.param((gen.generate(using: Ansi.arbitrary)) as Paramable))
    params.append(.param((gen.generate(using: Bash.arbitrary)) as Paramable))
    params.append(.param((gen.generate(using: Color.arbitrary)) as Paramable))
    params.append(.param((gen.generate(using: Dropdown.arbitrary)) as Paramable))
    params.append(.param((gen.generate(using: Emojize.arbitrary)) as Paramable))
    params.append(.param((gen.generate(using: Font.arbitrary)) as Paramable))
   params.append(.param((gen.generate(using: Href.arbitrary)) as Paramable))
//    params.append((gen.generate(using: Image.arbitrary)) as Paramable)
    params.append(.param((gen.generate(using: Length.arbitrary)) as Paramable))
    params.append(.param((gen.generate(using: Refresh.arbitrary)) as Paramable))
    params.append(.param((gen.generate(using: Size.arbitrary)) as Paramable))
    // TODO: Re-add
    // params.append((gen.generate(using: TemplateImage.arbitrary)) as Param)
    params.append(.param((gen.generate(using: Terminal.arbitrary)) as Paramable))
    params.append(.param((gen.generate(using: Trim.arbitrary)) as Paramable))

    // TODO: Change to 0
//    for named in gen.generate(using: NamedParam.arbitrary.proliferateRange(1, 10)) {
//      params.append(.param(named as Paramable))
//    }

    return params.shuffle()
  }

  func equals(_ other: Menuable) -> Bool {
    if other.headline != headline {
      return fail("Titles arnt matching", other.headline.string, headline.string)
    }

    if other.menus.count != menus.count {
      return fail("Sub menu count differs", other, self)
    }

    for (index, menu) in menus.enumerated() {
      if !menu.equals(other.menus[index]) {
        return fail("Menus are not equal")
      }
    }

    if other.level != level {
      return fail("Incorrect level", other.level, level)
    }

    for (index, param) in lines.enumerated() {
      if param.output != other.lines[index].output {
        return fail("Params are not equal", param, other.params[index])
      }
    }

    return true
  }

  private func fail(_ any: Any...) -> Bool {
    puts(any)
    return false
  }
}
