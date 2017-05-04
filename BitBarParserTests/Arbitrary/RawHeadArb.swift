import SwiftCheck
@testable import BitBarParser

extension Raw.Head: Arbable {
  typealias Head = Raw.Head
  typealias Tail = Raw.Tail
  typealias Param = Raw.Param

  public static var arbitrary: Gen<Head> {
    return Gen.compose { c in
      return Head(
        title: c.generate(using: string),
        params: c.generate(using: Param.params2.shuffle()),
        menus: c.generate(using: Raw.Tail.arbitrary.proliferate(withSize: 5))
      )
    }
  }

  var output: String {
    switch (params.isEmpty, menus.isEmpty) {
    case (true, true):
      return head + "\n"
    case (true, false):
       return head + "\n---\n" + tail
    case (false, true):
      return head + "| " + middle + "\n"
    case (false, false):
       return head + "| " + middle + "\n---\n" + tail
    }
  }

  static func ==== (lhs: Raw.Head, rhs: Raw.Head) -> Property {
    return lhs.title ==== rhs.title
      ^&&^ lhs.params ==== rhs.params
      ^&&^ lhs.menus ==== rhs.menus
  }

  private var tail: String { return menus.map { $0.output }.joined() }
  private var head: String { return title.titled() }
  private var middle: String { return params.map { $0.output }.joined(separator: " ") }
}
