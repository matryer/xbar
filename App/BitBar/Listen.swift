import EmitterKit

/**
 Used in AppDelegate to observe notifications
*/

class Listen {
  private var units = [EventUnit]()
  private let center: NotificationCenter

  init(_ center: NotificationCenter) {
    self.center = center
  }

  func on(_ name: Notification.Name, for object: AnyObject? = nil, block: @escaping Block<Void>) {
    units.append(EventUnit(center, name: name, object: object, block: block))
  }

  func reset() {
    for unit in units {
      center.removeObserver(unit)
    }

    units = []
  }
}

private class EventUnit {
  var listeners = [Listener]()
  let event = Event<Void>()

  init(_ center: NotificationCenter, name: Notification.Name, object: AnyObject?, block: @escaping Block<Void>) {
    center.addObserver(
      self,
      selector: #selector(didCallNotification),
      name: name,
      object: object
    )

    listeners.append(event.on(block))
  }

  @objc private func didCallNotification() {
    event.emit()
  }
}
