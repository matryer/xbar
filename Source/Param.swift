import Foundation

protocol Paramable: class, CustomStringConvertible {
  var priority: Int { get }
  var output: String { get } /* I.e: bash="/a/b/c.sh" */
  var key: String { get } /* I.e: bash */
  var original: String { get } /* I.e: "/a/b/c.sh" */
  var raw: String { get } /* I.e: /a/b/c.sh */
  func menu(didLoad: Menuable)
  func menu(didClick: Menuable)
  func equals(_ other: Paramable) -> Bool
}

extension Paramable {
  var priority: Int { return 0 }
  public var description: String {
    return output
  }

  var output: String {
    return key + "=" + original
  }


  func equals(_ param: Paramable) -> Bool {
    return output == param.output
  }
}

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
