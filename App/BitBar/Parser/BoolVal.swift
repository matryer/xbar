class BoolVal {
  var value: Bool

  init(_ value: Bool) {
    self.value = value
  }

  func toString() -> String {
    return String(value)
  }

  func getValue() -> Bool {
    return value
  }

  func equals(_ aValue: Any) -> Bool {
    guard let unpacked = aValue as? Bool else {
      return false
    }

    return value == unpacked
  }
}
