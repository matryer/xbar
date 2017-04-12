import GameKit

extension Array {
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

  func shuffle() -> [Any] {
    if #available(OSX 10.11, *) {
      return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self)
    } else {
      return self // TODO: Implement
    }
  }

  func some(block: (Element) -> Bool) -> Bool {
    return reduce(false) { acc, el in
      return acc || block(el)
    }
  }

  func all(block: (Element) -> Bool) -> Bool {
    if isEmpty { return true }
    return reduce(true) { acc, el in
      return acc && block(el)
    }
  }
}
