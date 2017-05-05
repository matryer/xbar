import Foundation

class Buffer {
  enum NotFound: Error {
    case noLocation
  }

  private static let defaultDelimiter = "~~~\n"
  private let del: String
  private let store: NSMutableData = NSMutableData(length: 0)!
  internal var hasData = false
  internal var isClosed = false

  convenience init() {
    self.init(withDelimiter: Buffer.defaultDelimiter)
  }

  init(withDelimiter del: String) {
    self.del = del
  }

  private var delimiter: Data {
    return del.toData()
  }

  func append(data: Data) {
    orFail()
    hasData = true
    store.append(data)
  }

  func append(string: String) {
    append(data: string.toData())
  }

  func isFinish() -> Bool {
    orFail()
    do {
      _ = try store.range(of: delimiter)
    } catch NotFound.noLocation {
      return false
    } catch (_) {
      return false
    }

    return true
  }

  func toString() -> String {
    // TODO: Handle error more gracefully
    return store.toString().remove(del)
  }

  func close() {
    isClosed = true
  }

  func reset() -> [String] {
    orFail()

    if store.length > 0 {
      hasData = true
    } else {
      hasData = false
    }

    var range: CRange!

    do {
      range = try store.range(of: delimiter)
    } catch NotFound.noLocation {
      return []
    } catch (_) {
      return []
    }

    let result = store.subdata(with: 0...range.upperBound)
    let remaining = store.subdata(with: range.upperBound...store.length)
    store.setData(remaining)
    return [result.toString().remove(del)] + reset()
  }

  private func orFail() {
    // TODO: Handle error in a better way
    if isClosed {
      preconditionFailure("[BUG] Buffer is closed")
    }
  }
}
