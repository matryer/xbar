import EmitterKit

class GEvent {
  let listener: () -> ()
  // let event = Event<Void>()
  var center: NotificationCenter

  init(_ center: NotificationCenter, name: Notification.Name, object: AnyObject?, block: @escaping Block<Void>) {
    self.listener = block
    self.center = center
    center.addObserver(
      self,
      selector: #selector(didCallNotification),
      name: name,
      object: object
    )
  }

  @objc private func didCallNotification() {
    listener()
  }

  func destroy() {
    center.removeObserver(self)
  }

  deinit {
    destroy()
  }
}
