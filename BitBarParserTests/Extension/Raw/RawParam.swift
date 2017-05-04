@testable import BitBarParser

extension Raw.Param: CustomStringConvertible {
  public var description: String {
    return output.inspected()
  }
}
