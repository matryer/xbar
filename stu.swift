// A
// --B
// ----C
// -------D
// E
//
// A -> (B -> C -> D) -> E
// A -> E
//
// /
// typealias X = (String, Int, )
// typealias That<T> = (String, Int, [(String, Int, X)])
// typealias Source = That<Source>
func toValue(_ value: String, _ level: Int) -> Source {
  return .item(value, level, [Source]())
}

indirect enum Source {
  case item(String, Int, [Source])
}

let parent = toValue("P", 0)
var values = [Source]()
values.append(toValue("A", 1))
values.append(toValue("B", 2))
values.append(toValue("C", 3))
values.append(toValue("D", 4))
values.append(toValue("E", 1))

extension Source: CustomStringConvertible {
  var description: String {
    switch self {
    case let .item(value, level, sources):
      return (0..<level).map { _ in "--" }.joined(separator: "") + value + "\n" +
        sources.map { String(describing: $0) }.joined(separator: "")
    }
  }
}
// [[A, 1], [B, 2], [C, 3], [D, 4], [E, 1]
// =>
// [A -> [B -> [C -> [D -> []]]], E -> []]

let result = values.reduce(parent) { parent, item in
  switch (parent, item) {
  case let (.item(v1, l1, xs), .item(_, l2, _)) where l1 < l2:
    return .item(v1, l1, xs + [item])
  default:
    preconditionFailure("invalid state")
  }
}

print(result)
