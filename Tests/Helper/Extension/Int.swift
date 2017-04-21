extension Int {
  func times<T>(block: (Int) -> T) -> [T] {
    guard self >= 0 else {
      preconditionFailure("Int can't be equal or less then zero")
    }

    return (0..<self).map { index in
      return block(index)
    }
  }
}
