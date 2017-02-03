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

}

extension Array where Iterator.Element == String {
  // To lazy to type {separator}
  func joined(_ sep: String = "") -> String {
    return joined(separator: sep)
  }
}
