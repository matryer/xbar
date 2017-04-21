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
