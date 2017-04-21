import SwiftCheck

extension Array {
  var any: Gen<Element> {
    return Gen<Element>.fromElements(of: self)
  }
}
