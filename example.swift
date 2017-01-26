import Swift
import Foundation

// protocol Base: class {
//   func equals(r: Base) -> Bool
// }

// class X: Base {
//   func equals(r: Base) -> Bool {
//     return false
//   }
// }

// class Y: Base {
//   func equals(r: Base) -> Bool {
//     return false
//   }
// }

// var list = [Base]()
// list.append(Y())
// list.append(X())

// let res = list.sorted { (a,b) in a.equals(r: b) }
// dump(res)

// @objc class X {

// }
// @objc protocol Param: class {
//   @objc optional func menu(didLoad: X)
//   var priority: Int { get }
//   func equals(_ param: Param) -> Bool
// }

// extension Param {
//   var key: String {
//     return String(describing: type(of: self))
//   }
// }

protocol A: CustomStringConvertible {
  var values: [String: Any] { get }
}

extension A {
  public var name: String {
    return String(describing: type(of: self))
  }

  public var description: String {
    var res = ""
    for (key, value) in values {
      res += " " + key + "=" + String(describing: value)
    }
    return "<\(name): \(res)>"
  }
}

class C: A {
  var values: [String: Any] {
    return ["hellp": 8, "xxx": "OKA"]
  }
}

// class B: A {
//   func toString() -> String {
//     return "B"
//   }
// }

print(String(describing: C()))
