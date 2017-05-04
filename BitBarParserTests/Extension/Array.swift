import SwiftCheck

extension Array {
  var any: Gen<Element> {
    return Gen<Element>.fromElements(of: self)
  }

  func shuffle<T>() -> Gen<[T]> where Element == Gen<T> {
    return Gen<Element>.fromShufflingElements(of: self).flatMap(sequence)
  }

  func one<T>() -> Gen<T> where Element == Gen<T> {
    return Gen<T>.one(of: self)
  }

  func get(at index: Int) -> Element? {
    if count <= index { return nil }
    return self[index]
  }

  // @example [1,2,3].all { $0 > 2 } // => true
  // func some(block: (Element) -> Bool) -> Bool {
  //   return reduce(false) { acc, el in
  //     return acc || block(el)
  //   }
  // }
  //
  // // @example [1,2,3].all { $0 > 0 } // => true
  // public func all(block: (Element) -> Bool) -> Bool {
  //   if isEmpty { return true }
  //   return reduce(true) { acc, el in
  //     return acc && block(el)
  //   }
  // }

  // @example [1,2,3].all { $0 > 2 } // => true
  func some(block: (Element) -> Any) -> Property {
    return reduce(false ^&&^ false) { acc, el in
      let res = block(el)
      switch res {
      case is Bool:
        return acc ^||^ (res as! Bool)
      case is Property:
        return acc ^||^ (res as! Property)
      default:
        preconditionFailure("invalid type")
      }
    }
  }

  // @example [1,2,3].all { $0 > 0 } // => true
  func all(block: (Element) -> Any) -> Property {
    return reduce(true ^&&^ true) { acc, el in
      let res = block(el)
      switch res {
      case is Bool:
        return acc ^&&^ (res as! Bool)
      case is Property:
        return acc ^&&^ (res as! Property)
      default:
        preconditionFailure("invalid type")
      }
    }
  }
}
