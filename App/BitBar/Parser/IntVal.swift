// TODO: Rename to IntVal
class IntValue: Param {
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

  func applyTo(menu: Menuable) {
    // TODO
  }
}
