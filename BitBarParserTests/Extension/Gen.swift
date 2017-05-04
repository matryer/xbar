import SwiftCheck

extension Gen {
  public func proliferateRange(_ min: Int, _ max: Int) -> Gen<[A]> {
    return Gen.choose((min, max)).flatMap(self.proliferate(withSize:))
  }
}
