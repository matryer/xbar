import Foundation

class Param<T: Equatable>: Paramable, Equatable {
  var original: String { return raw }
  var raw: String { return String(describing: value) }
  var key: String {
    return String(describing: type(of: self)).camelCase
  }
  var value: T

  init(_ value: T) {
    self.value = value
  }

  static func ==(lhs: Param<T>, rhs: Param<T>) -> Bool {
    guard type(of: lhs.value) == type(of: rhs.value) else {
      return false
    }

    return lhs.value == rhs.value
  }

   func menu(didLoad: Menuable) {
     // preconditionFailure("didLoad not implement for \(key)")
   }

   func menu(didClick: Menuable) {
     // preconditionFailure("didClick not implement for \(key)")
   }
}
