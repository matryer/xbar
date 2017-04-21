import Foundation

class Buffer {
  enum NotFound: Error {
    case noLocation
  }

  private static let defaultDelimiter = "\n~~~\n".toData()
  private let delimiter: Data
  private let store: NSMutableData = NSMutableData(length: 0)!
  internal var hasData = false
  internal var isClosed = false

  init() {
    self.delimiter = Buffer.defaultDelimiter
  }

  init(withDelimiter: String) {
    self.delimiter = withDelimiter.toData()
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
    return store.toString()
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
    return [result.toString()] + reset()
  }

  private func orFail() {
    // TODO: Handle error in a better way
    if isClosed {
      preconditionFailure("[BUG] Buffer is closed")
    }
  }
}
