protocol Parent: class {
  weak var root: Parent? { get set }
  func on(_ event: MenuEvent)
  func broadcast(_ event: MenuEvent)
}

extension Parent {
  func broadcast(_ event: MenuEvent) {
    if let aRoot = root {
      aRoot.on(event)
      aRoot.broadcast(event)
    } else {
      print("[Log] No root found for \(self)")
    }
  }

  func on(_ event: MenuEvent) {
    /* NOP */
  }
}
