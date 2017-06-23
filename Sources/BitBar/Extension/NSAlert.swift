import Cocoa

extension NSAlert: GUI {
  var queue: DispatchQueue {
    return NSAlert.newQueue(label: "Alert")
  }

  func append(text: String) {
    messageText += text
  }

  func display() {
    perform { self.runModal() }
  }
}
