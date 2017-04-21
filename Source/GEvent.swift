import EmitterKit

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
