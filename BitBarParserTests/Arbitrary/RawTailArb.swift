import SwiftCheck
@testable import BitBarParser

extension Raw.Tail: Arbable {
  typealias Tail = Raw.Tail
  typealias Param = Raw.Param

  public static var arbitrary: Gen<Tail> {
    return Gen.compose { gen in
      return Tail(
        level: gen.generate(using: Int.arbitrary.suchThat { $0 >= 0 }),
        title: gen.generate(using: string),
        params: gen.generate(using: Param.params.shuffle())
      )
    }
  }

  public static func ==== (lhs: Tail, rhs: Tail) -> Property {
    return lhs.title ==== rhs.title
      ^&&^ lhs.params ==== rhs.params
      ^&&^ lhs.level ==== rhs.level
  }

  var output: String {
    if params.isEmpty {
      return indent + title.titled() + "\n"
    }

    return indent + title.titled() + "| " + params
      .map { $0.output }.joined(separator: " ") + "\n"
  }

  var indent: String {
    return (0..<level).map { _ in "--" }.joined()
  }
}
