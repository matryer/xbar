class StringVal: Param {
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

  func applyTo(menu: Menuable) {
    // TODO: Remove
  }
}
