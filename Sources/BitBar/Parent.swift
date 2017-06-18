import SwiftyBeaver

protocol Parent: class {
  var log: SwiftyBeaver.Type { get }
  weak var root: Parent? { get set }
  func on(_ event: MenuEvent)
  func broadcast(_ event: MenuEvent)
}

extension Parent {
  var owner: String {
    return String(describing: type(of: self))
  }

  func broadcast(_ event: MenuEvent) {
    if let aRoot = root {
      log.verbose("[\(owner)] Broadcasting event \(event)")
      aRoot.on(event)
      aRoot.broadcast(event)
    } else {
      log.warning("[\(owner)] No root found")
    }
  }

  func on(_ event: MenuEvent) {
    log.verbose("[\(owner)] Unhandled event \(event)")
  }
}
