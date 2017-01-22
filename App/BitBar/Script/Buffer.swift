import Foundation

class Buffer {
  private let store: NSMutableData = NSMutableData(length: 0)!
  internal var isClosed = false

  func append(data: Data) {
    orFail()
    store.append(data)
  }

  func isFinish() -> Bool {
    orFail()
    return toString().contains("~~~")
  }

  func toString() -> String {
    // TODO: Handle error more gracefully
    return String(data: store as Data, encoding: .utf8)!
  }

  func close() {
    isClosed = true
  }

  func reset() -> String {
    orFail()
    let output = toString()
    store.setData(NSData() as Data)
    return output
  }

  private func orFail() {
    // TODO: Handle error in a better way
    if isClosed {
      preconditionFailure("[BUG] Buffer is closed")
    }
  }
}
