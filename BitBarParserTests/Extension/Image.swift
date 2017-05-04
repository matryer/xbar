import SwiftCheck
@testable import BitBarParser

extension Image: CustomStringConvertible {
  public var description: String {
    return output.escaped()
  }
}
