import EmitterKit

/**
 Used in AppDelegate
*/

private class EventUnit {
  var listeners = [Listener]()
  let event = Event<Void>()

  init(_ center: NotificationCenter, name: Notification.Name, block: @escaping Block<Void>) {
    center.addObserver(
      self,
      selector: #selector(didCallNotification),
      name: name,
      object: nil
    )

    listeners.append(event.on(block))
  }

  @objc private func didCallNotification() {
    event.emit()
  }
}

class Listen {
  private var units = [EventUnit]()
  private let center: NotificationCenter

  init(_ center: NotificationCenter) {
    self.center = center
  }

  func on(_ name: Notification.Name, block: @escaping Block<Void>) {
    units.append(EventUnit(center, name: name, block: block))
  }
}
