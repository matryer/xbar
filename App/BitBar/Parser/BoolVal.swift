class BoolVal: Param {
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

  func applyTo(menu: MenuDelegate) {
    // TODO:
  }
}
