class BoolVal: Val {
  var value: String { return String(bool) }
  var values: [String: Any] {
    return ["bool": bool]
  }

  let bool: Bool

  init(_ bool: Bool) {
    self.bool = bool
  }

  func equals(_ param: Param) -> Bool {
    if let value = param as? BoolVal {
      if value.key != key { return false }
      return value.bool == bool
    }

    return false
  }
}

class StringVal: Val {
  var values: [String: Any] {
    return ["value": value]
  }

  let value: String

  init(_ value: String) {
    self.value = value
  }

  func equals(_ param: Param) -> Bool {
    if let value = param as? StringVal {
      if value.key != key { return false }
      return value.value == self.value
    }

    return false
  }

}

class FloatVal: Val {
  var value: String { return String(Int(float)) }
  var values: [String: Any] {
    return ["float": float]
  }

  let float: Float

  init(_ float: Float) {
    self.float = float
  }

  init(_ int: Int) {
    self.float = Float(int)
  }

  func equals(_ param: Param) -> Bool {
    if let float = param as? FloatVal {
      if float.key != key { return false }
      return float.float == self.float
    }

    return false
  }
}

class IntVal: Val {
  var value: String { return String(int) }
  var values: [String: Any] {
    return ["int": int]
  }

  let int: Int

  init(_ int: Int) {
    self.int = int
  }

  func equals(_ param: Param) -> Bool {
    if let value = param as? IntVal {
      if value.key != key { return false }
      return value.int == int
    }

    return false
  }
}
