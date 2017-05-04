@testable import BitBarParser

extension Raw.Head: CustomStringConvertible {
  public var description: String {
    return output.inspected()
  }
}
