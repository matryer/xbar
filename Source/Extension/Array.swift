import Dollar

extension Array {
  func appended(_ element: Element) -> [Element] {
    return self + [element]
  }
}

extension Array where Element: Equatable {
  func has(_ el: Element) -> Bool {
    return $.contains(self, value: el)
  }
}
