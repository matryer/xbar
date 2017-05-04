@testable import BitBarParser

extension Raw.Tail: CustomStringConvertible {
  public var description: String {
    return output.inspected()
  }
}
