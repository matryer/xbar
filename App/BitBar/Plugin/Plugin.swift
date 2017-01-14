import AppKit
import Swift

class Plugin: Base {
  let file: File
  let path: String
  let tray: Tray = Tray(title: "…")
  let manager: PluginManager

  init(path: String, file: File, manager: PluginManager) {
    self.file = file
    self.path = path
    self.manager = manager
    tray.delegate = manager
    super.init()
  }

  func getTime() -> Double {
    return Double(file.interval)
  }

  func getName() -> String {
    return file.name
  }

  func didReceivedOutput(_ data: String) {
    log("didReceivedOutput", "'" + data + "'")
    switch Pro.parse(Pro.getOutput(), data) {
    case let Result.success(output, _):
      output.title.onDidRefresh { self.refresh() }
      output.title.applyTo(tray: tray)
    case let Result.failure(error):
      didReceiveError(String(describing: error))
    }
  }

  func didReceiveError(_ data: String) {
    log("didReceiveError", "'" + data + "'")
    tray.clear(title: "Error...")
  }

  func refresh() {
    preconditionFailure("This method must be overridden")
  }

  func show() {
    preconditionFailure("This method must be overridden")
  }

  func hide() {
    preconditionFailure("This method must be overridden")
  }

  func destroy() {
    hide()
  }
}
