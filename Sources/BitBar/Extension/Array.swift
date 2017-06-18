import Dollar

extension Array where Element: Equatable {
  func has(_ el: Element) -> Bool {
    return $.contains(self, value: el)
  }
}

extension Array where Element == String {
  func join(_ sep: String) -> String {
    return joined(separator: sep)
  }
}
