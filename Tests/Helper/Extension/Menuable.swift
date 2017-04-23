@testable import BitBar

extension Menuable {
  var body: String {
    return escape(title: headline.string) + pstr + "\n" + menus.map { $0.getInput() }.joined() + "\n"
  }

  var pstr: String {
    if lines.isEmpty { return "" }
    return "| " + lines.map { param in param.output }.joined(separator: " ")
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
