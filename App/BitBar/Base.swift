import Swift
import Foundation

class Base: NSObject {
  func log(_ org: String, _ message: String) {
    print(toString() + "#" + org + ":", message)
  }

  func toString() -> String {
    return String(describing: self)
  }
}
