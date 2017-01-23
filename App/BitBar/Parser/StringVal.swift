class StringVal {
  var value: String

  init(_ value: String) {
    self.value = value
  }

  func getValue() -> String {
    return value
  }

  func toString() -> String {
    return value
  }

  static func == (_ this: StringVal, _ that: StringVal) -> Bool {
    return this.value == that.value
  }

  func equals(_ aValue: Any) -> Bool {
    guard let unpacked = aValue as? String else {
      return false
    }

    return value == unpacked
  }
}
