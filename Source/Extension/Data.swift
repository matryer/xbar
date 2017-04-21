import Foundation

extension Data {
  func toString() -> String {
    return String(data: self, encoding: .utf8)!
  }

  func isEOF() -> Bool {
    return count == 0
  }
}
