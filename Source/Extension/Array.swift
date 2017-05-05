import Dollar

extension Array where Element: Equatable {
  func has(_ el: Element) -> Bool {
    return $.contains(self, value: el)
  }
}
