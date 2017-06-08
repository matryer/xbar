class Storage {
  var store = [String: String]()

  func get(_ key: String, default otherwise: String) -> String {
    if let value = store[key] {
      return value
    }

    return otherwise
  }

  func set(_ key: String, value: String) {
    store[key] = value
  }
}
