import EmitterKit

class Phase: NSObject {
  let event = Event<Void>()
  let listener: Listener

  init(_ object: AnyObject, block: @escaping (AnyObject) -> Void) {
    listener = event.on { [weak object] in
      if let that = object {
        block(that)
      }
    }
  }

  @objc func onDidClick() {
    event.emit()
  }
}
