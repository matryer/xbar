protocol Param: class {
  func toString() -> String
  func applyTo(menu: Menuable)
  func equals(_ value: Any) -> Bool
  var priority: Int { get }
}

extension Param {
  var key: String {
    return String(describing: type(of: self))
  }

  func equals(_ value: Any) -> Bool {
    preconditionFailure("This method must be overridden")
  }
}
