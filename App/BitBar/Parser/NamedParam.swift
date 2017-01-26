final class NamedParam: Param {
  var priority = 0
  let value: String
  let index: Int
  var values: [String: Any] {
    return ["value": value, "index": index]
  }

  init(key: String, value: String) {
    self.index = Int(key)!
    self.value = value
  }

  var string: String {
    return "param" + String(index) + "=" + value
  }

  func equals(_ param: Param) -> Bool {
    if let named = param as? NamedParam {
      if named.index != index { return false }
      if named.value != value { return false }
      return true
    }

    return false
  }
}
