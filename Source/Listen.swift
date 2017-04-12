import EmitterKit

/**
 Used in AppDelegate and Script to observe notifications
*/
class Listen {
  private let center: NotificationCenter

  init(_ center: NotificationCenter) {
    self.center = center
  }

  func on(_ name: Notification.Name, for object: AnyObject? = nil, block: @escaping Block<Void>) -> GEvent {
    return GEvent(center, name: name, object: object, block: block)
  }
}

class GEvent {
  let listener: Listener
  let event = Event<Void>()
  var center: NotificationCenter

  init(_ center: NotificationCenter, name: Notification.Name, object: AnyObject?, block: @escaping Block<Void>) {
    self.listener = event.on(block)
    self.center = center
    center.addObserver(
      self,
      selector: #selector(didCallNotification),
      name: name,
      object: object
    )
  }

  @objc private func didCallNotification() {
    event.emit()
  }

  func destroy() {
    center.removeObserver(self)
  }

  deinit {
    destroy()
  }
}
