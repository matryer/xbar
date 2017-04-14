import Foundation

extension NSRange {
  var new: CountableClosedRange<Int> {
    return location...(location + length)
  }
}

typealias CRange = CountableClosedRange<Int>
extension CountableClosedRange where  Bound : Integer {
  var old: NSRange {
    let upper = upperBound as! Int
    let lower = lowerBound as! Int
    return NSRange(location: lower, length: upper - lower)
  }
}

// TODO: Make private
private enum NotFound: Error {
  case noLocation
}

private extension NSMutableData {
  func range(of data: Data) throws -> CRange {
    let foundRange = range(of: data, in: (0...length).old)

    if foundRange.location == NSNotFound {
      throw NotFound.noLocation
    }

    return foundRange.new
  }

  func subdata(with range: CRange) -> Data {
    return subdata(with: range.old)
  }

  func reset() -> NSMutableData {
    return replace(with: NSMutableData(length: 0)! as Data)
  }

  func replace(with data: Data) -> NSMutableData {
    let current = self
    setData(data)
    return current
  }

  func toString() -> String {
    return (self as Data).toString()
  }
}

extension Data {
  func toString() -> String {
    return String(data: self, encoding: .utf8)!
  }
}

private extension String {
  func toData() -> Data {
    return data(using: .utf8)!
  }
}

class Buffer {
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
