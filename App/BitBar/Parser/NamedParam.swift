final class NamedParam: Param {
  var priority: Int { return 0 }
  let key: String
  let value: String

  init(key: String, value: String) {
    self.key = key
    self.value = value
  }

  func getValue() -> String {
    return value
  }

  func getKey() -> String {
    return key
  }

  func toString() -> String {
    return "param" + key + "=" + value
  }

  static func == (_ this: NamedParam, _ that: NamedParam) -> Bool {
    return this.key == that.key && this.value == that.value
  }

  func applyTo(menu: Menuable) {
    // TODO: Remove
  }

  func getIndex() -> Int {
    if let index = Int(key) {
      return index
    }

    return -1
  }
}
