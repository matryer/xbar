import SwiftCheck
@testable import BitBar

extension NamedParam: Base {
  static let head: Gen<String> = Gen<Int>.fromElements(in: 0...10000).map { String($0) }

  public static var arbitrary: Gen<NamedParam> {
    return Gen.compose { c in
      NamedParam(key: c.generate(using: head), value: c.generate(using: aWord()))
    }
  }

  func toString() -> String {
    return getInput()
  }

  func test(_ param: NamedParam) -> Property {
    return param.key ==== self.key ^&&^ param.value ==== value
  }
}
