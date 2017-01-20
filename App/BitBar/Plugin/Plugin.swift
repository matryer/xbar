import AppKit
import Swift

class Plugin: Base, TrayDelegate {
  let file: File
  let path: String
  let tray: Tray = Tray(title: "…")
  weak var delegate: TrayDelegate?

  init(path: String, file: File, delegate: TrayDelegate?) {
    self.file = file
    self.path = path
    self.delegate = delegate
    super.init()
    tray.delegate = self
  }

  func getTime() -> Double {
    return Double(file.interval)
  }

  func terminate() {
    tray.hide()
    hide()
  }

  func getName() -> String {
    return file.name
  }

  func didReceivedOutput(_ data: String) {
    // log("didReceivedOutput", "'" + data + "'")
    switch Pro.parse(Pro.getOutput(), data) {
    case let Result.success(output, _):
      output.title.onDidRefresh { self.refresh() }
      output.title.applyTo(tray: tray)
      tray.show()
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

  func preferenceDidOpenInTerminal() {
    Bash.open(script: path)
  }

  func preferenceDidRefreshAll() {
    delegate?.preferenceDidRefreshAll()
  }

  func preferenceDidQuit() {
    delegate?.preferenceDidQuit()
  }

  func preferenceDidChangePluginFolder() {
    delegate?.preferenceDidChangePluginFolder()
  }
}
