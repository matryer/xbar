import GameKit

extension Array {
  // @example [1,2].zip([4]) // => [(some(1), some(4)), (some(2), none)]
  func zip(with array: [Element]) -> [(Element?, Element?)] {
    var result = [(Element?, Element?)]()
    if count > array.count {
      for (index, item) in enumerated() {
        result.append((item, array.get(at: index)))
      }
    } else {
      for (index, item) in array.enumerated() {
        result.append((get(at: index), item))
      }
    }

    return result
  }

  func get(at index: Int) -> Element? {
    if count <= index { return nil }
    return self[index]
  }

  func shuffle() -> [Element] {
    if #available(OSX 10.11, *) {
      return GKRandomSource.sharedRandom()
        .arrayByShufflingObjects(in: self) as! [Element]
    } else {
      return self // TODO: Implement
    }
  }

  // @example [1,2,3].all { $0 > 2 } // => true
  func some(block: (Element) -> Bool) -> Bool {
    return reduce(false) { acc, el in
      return acc || block(el)
    }
  }

  // @example [1,2,3].all { $0 > 0 } // => true
  func all(block: (Element) -> Bool) -> Bool {
    if isEmpty { return true }
    return reduce(true) { acc, el in
      return acc && block(el)
    }
  }

  func first(block: (Element) -> Bool) -> Element? {
    return filter { block($0) }.get(at: 0)
  }

  func appended(_ element: Element) -> [Element] {
    return self + [element]
  }
}

extension Array where Element: Equatable {
  func includes(_ element: Element) -> Bool {
    return some { el in el == element }
  }
}
