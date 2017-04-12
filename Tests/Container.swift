import SwiftCheck
import GameKit
@testable import BitBar

extension Container: Base, Val {
  public var values: [String: Any] {
    return ["params": params, "has delegate": (delegate != nil)]
  }

  func getInput() -> String {
    if params.isEmpty { return "\n" }
    return "|" + params.map { $0.getInput() }
      .joined(separator: " ").trim() + "\n"
  }

  public static var arbitrary: Gen<Container> {
    return Gen.compose { gen in
      var params = [Param]()
      let container = Container()
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
      // TODO: Re-add
      // params.append((gen.generate(using: TemplateImage.arbitrary)) as Param)
      params.append((gen.generate(using: Terminal.arbitrary)) as Param)
      params.append((gen.generate(using: Trim.arbitrary)) as Param)

      // TODO: Change to 0
      for named in gen.generate(using: NamedParam.arbitrary.proliferateRange(1, 10)) {
        params.append(named as Param)
      }

      container.append(params: params.shuffle() as! [Param])
      return container
    }
  }

  func test(_ container: Container) -> Property {
    return container ==== self
  }
}
