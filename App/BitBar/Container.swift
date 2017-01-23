/**
  Represents zero or more params for a title or menu
*/
class Container {
  private var store = [String: [Param]]()
  internal weak var delegate: Menuable?

  var filterParams: [Param] {
    return params.reduce([]) { acc, param in
      if param is NamedParam { return acc }
      return acc + [param]
    }
  }

  var params: [Param] {
    return store.reduce([]) { acc, value in
      return acc + value.1
    }
  }

  init() { /* TODO: Remove this. Not sure why it's needed */ }

  /**
    Add @params to the collection
  */
  func append(params: [Param]) {
    var hasEmo = false
    for param in params {
      hasEmo = hasEmo || param is Emojize
      // TODO: Move String... to the param protocol
      let key = String(describing: type(of: param))
      if let curr = store[key] {
        store[key] = curr + [param]
      } else {
        store[key] = [param]
      }
    }

    if !hasEmo {
      append(params: [Emojize(true)])
    }
  }

  /**
    Represents the refresh param, i.e refresh=false
  */
  func shouldRefresh() -> Bool {
    return each(type: "Refresh", backup: false) {
      ($0 as? Refresh)?.getValue()
    }
  }

  /**
    Represents the dropdown param, i.e dropdown=false
  */
  func hasDropdown() -> Bool {
    return each(type: "Dropdown", backup: true) {
      ($0 as? Dropdown)?.getValue()
    }
  }

  /**
    Represents the terminal param, i.e terminal=false
  */
  func openTerminal() -> Bool {
    return each(type: "Terminal", backup: false) {
      ($0 as? Terminal)?.getValue()
    }
  }

  func apply() {
    if let menu = delegate {
      for param in params {
        param.applyTo(menu: menu)
      }
    }
  }

  /**
    Params to be passed as argument to a bash script
  */
  var args: [String] {
    return namedParams.sorted {
      return $0.getIndex() < $1.getIndex()
    }.map { $0.getValue() }
  }

  /**
    Represents the a list of the param-param, i.e param1=<value>
  */
  var namedParams: [NamedParam] {
    return get(type: "NamedParam").reduce([]) {
      if let param = $1 as? NamedParam {
        return $0 + [param]
      }

      return $0
    }
  }

  private func get(type: String) -> [Param] {
    return store[type] ?? []
  }

  private func each(type: String, backup: Bool, block: (Param) -> Bool?) -> Bool {
    for param in get(type: type) {
      guard let bool = block(param) else {
        continue
      }

      return bool
    }

    return backup
  }

}
