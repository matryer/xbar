protocol TrayDelegate: class {
  func tray(didClickOpenInTerminal: Tray)
  func tray(didTriggerRefresh: Tray)
}
