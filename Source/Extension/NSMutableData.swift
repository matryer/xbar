import Foundation

extension NSMutableData {
  func range(of data: Data) throws -> CRange {
    let foundRange = range(of: data, in: (0...length).old)

    if foundRange.location == NSNotFound {
      // FIXME: Not sure its a good idea to keep
      // NSMutableData and Buffer coupled
      throw Buffer.NotFound.noLocation
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
