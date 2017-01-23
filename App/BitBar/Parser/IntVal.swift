// TODO: Rename to IntVal
class IntValue {
  var value: Int

  init(_ value: Int) {
    self.value = value
  }

  func toString() -> String {
    return String(value)
  }

  static func == (_ this: IntValue, _ that: IntValue) -> Bool {
    return this.value == that.value
  }

  func getValue() -> Int {
    return value
  }

  func equals(_ aValue: Any) -> Bool {
    guard let unpacked = aValue as? Int else {
      return false
    }

    return value == unpacked
  }
}
