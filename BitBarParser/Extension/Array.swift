extension Array {
  // @example [1,2,3].all { $0 > 2 } // => true
  // func some(block: (Element) -> Bool) -> Bool {
  //   return reduce(false) { acc, el in
  //     return acc || block(el)
  //   }
  // }

  func initial() -> [Element] {
    if count <= 1 { return [] }
    return (0..<(count - 1)).map { self[$0] }
  }
}
