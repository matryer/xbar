import Foundation
import Swift

protocol Val: class, CustomStringConvertible {
  var key: String { get }
  var values: [String: Any] { get }
}

extension Val {
  public var key: String {
    return String(describing: type(of: self))
  }

  public var description: String {
    var res = ""
    for (key, value) in values {
      res += key + "=" + String(describing: value) + " "
    }

    return "<\(key): \(res)>"
  }
}

protocol Param: Val {
  var priority: Int { get }
  var value: String { get }
  func equals(_ param: Param) -> Bool

  func menu(didLoad: Menuable)
  func menu(didClick: Menuable)
}

extension Param {
  var key: String {
    return String(describing: type(of: self))
  }

  func menu(didLoad: Menuable) {
    /* Default */
  }

  func menu(didClick: Menuable) {
    /* Default */
  }

//  public static func <(lhs: Param, rhs: Param) -> Bool {
//    return lhs.priority > rhs.priority
//  }
}
