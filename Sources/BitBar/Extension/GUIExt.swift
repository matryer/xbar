import Foundation
import Async

extension GUI {
  static func newQueue(label: String) -> DispatchQueue {
    return DispatchQueue(label: label, target: .main)
  }

  internal func perform(block: @escaping () -> Void) {
    if App.isInTestMode() { return block() }
    Async.custom(queue: queue) { block() }
  }
}
