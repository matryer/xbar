import Swift
import Foundation

class Base: NSObject {
  internal func log(_ org: String, _ message: String) {
    print(toString() + "#" + org + ":", message)
  }

  internal func toString() -> String {
    return String(describing: self)
  }
}
