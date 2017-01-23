import Cent

/**
  Represents zero or more params for a title or menu
*/
class Container {
  private var store = [String: [Param]]()
  internal weak var delegate: Menuable?

  /**
    A non-sorted list of non named params, i.e terminal=false
  */
  var filterParams: [Param] {
    return params.reduce([]) { acc, param in
      if param is NamedParam { return acc }
      return acc + [param]
    }
  }

  /**
    A non sorted list of all params
    I.e terminal=false, param7=2
  */
  var params: [Param] {
    return store.reduce([]) { acc, value in
      return acc + value.1
    }
  }

  /**
    Params to be passed as argument to a bash script
    Sorted. I.e param2="A", param1="B"
    Becomes ["B", "A"]
  */
  var args: [String] {
    return namedParams.sorted {
      return $0.getIndex() < $1.getIndex()
    }.map { $0.getValue() }
  }

  /**
    Represents the a list named params, i.e param1="B"
  */
  var namedParams: [NamedParam] {
    return get(type: "NamedParam").reduce([]) {
      if let param = $1 as? NamedParam {
        return $0 + [param]
      }

      return $0
    }
  }

  init() {
    add(param: Emojize(true))
    add(param: Trim(true))
  }

  /**
    Add @params to the collection
  */
  func append(params: [Param]) {
    for param in params {
      add(param: param)
    }
  }

  func add(param: Param) {
    add(type: param.key, value: param)
  }

  /**
    Represents the refresh param, i.e refresh=false
  */
  func shouldRefresh() -> Bool {
    return last(type: "Refresh")?.equals(true) ?? false
  }

  /**
    Represents the dropdown param, i.e dropdown=false
  */
  func hasDropdown() -> Bool {
    return last(type: "Dropdown")?.equals(true) ?? true
  }

  /**
    Represents the terminal param, i.e terminal=false
  */
  func openTerminal() -> Bool {
    return last(type: "Terminal")?.equals(true) ?? true
  }

  func apply() {
    // FIXME: Don't sort 'ondemand'
    let sortedParams = self.filterParams.sorted { (p1, p2) in
      return p1.priority > p2.priority
    }

    if let menu = delegate {
      for param in sortedParams {
        param.applyTo(menu: menu)
      }
    }
  }

  private func get(type: String) -> [Param] {
    return store[type] ?? []
  }

  private func has(type: String) -> Bool {
    return !get(type: type).isEmpty
  }

  private func add(type: String, value: Param) {
    if value is NamedParam {
      // Append
      if let current = store[type] {
        store[type] = current + [value]
      } else {
        store[type] = [value]
      }
    } else {
      // Override existing value
      store[type] = [value]
    }
  }

  // Selectors first item of @type
  func last(type: String) -> Param? {
    return get(type: type).last()
  }

  static func == (_ lhs: Container, _ rhs: Container) -> Bool {
    if lhs.filterParams.count != rhs.filterParams.count {
      return false
    }

    if lhs.args.count != rhs.args.count {
      return false
    }

    if lhs.params.count != rhs.params.count {
      return false
    }

    for param1 in lhs.filterParams {
      if let param2 = rhs.last(type: param1.key) {
        if param1.toString() != param2.toString() {
          return false
        }
      } else {
        return false
      }
    }

    for (index, arg1) in lhs.args.enumerated() {
      if rhs.args[index] != arg1 {
        return false
      }
    }

    return true
  }
}
