/**
  Represents zero or more params for a title or menu
*/
class Container {
  private var store = [String: [Param]]()
  internal weak var delegate: MenuDelegate?

  init() {
    /* TODO: Remove this. Not sure why it's needed */
  }

  func append(params: [Param]) {
    for param in params {
      let key = String(describing: type(of: param))
      if let curr = store[key] {
        store[key] = curr + [param]
      } else {
        store[key] = [param]
      }
    }
  }

  func shouldRefresh() -> Bool {
    return each(type: "Refresh", backup: false) {
      ($0 as? Refresh)?.getValue()
    }
  }

  func hasDropdown() -> Bool {
    return each(type: "Dropdown", backup: true) {
      ($0 as? Dropdown)?.getValue()
    }
  }

  func openTerminal() -> Bool {
    return each(type: "Terminal", backup: false) {
      ($0 as? Terminal)?.getValue()
    }
  }

  func apply() {
    guard let menu = delegate else {
      return
    }

    for param in params {
      param.applyTo(menu: menu)
    }
  }

  var args: [String] {
    return get(type: "NamedParam").sorted {
      guard let param1 = $0 as? NamedParam else {
        return false
      }

      guard let param2 = $1 as? NamedParam else {
        return false
      }

      return param1.getIndex() < param2.getIndex()
    }.reduce([]) {
      if let param = $1 as? NamedParam {
        return $0 + [param.getValue()]
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

  var params: [Param] {
    return store.reduce([]) { acc, value in
      if value.0 == "NamedParam" { return acc }
      return acc + value.1
    }
  }
}
