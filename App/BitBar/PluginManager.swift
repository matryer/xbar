import AppKit
import Swift
import Foundation
import Files

class PluginManager: Base {
  weak var delegate: AppDelegate?
  let path: String
  let workspace = NSWorkspace.shared
  let tray = Tray(title: "BitBar")
  var errors = [Tray]()
  var plugins = [Plugin]()

  init(path: String, delegate: AppDelegate?) {
    self.delegate = delegate
    tray.delegate = delegate
    self.path = path
    super.init()
    setPlugins()
  }

  private func setPlugins() {
    plugins = []

    do {
      for file in try Folder(path: path).files {
        if !file.name.hasPrefix(".") {
          addPlugin(file.name, path: file.path)
        }
      }
    } catch (let error) {
      show(error: String(describing: error))
    }

    if plugins.isEmpty {
      tray.show()
    } else {
      tray.hide()
    }
  }

  private func show(error: String) {
    Title(errors: [error]).applyTo(tray: tray)
  }

  /**
    Quit any current running background tasks and removes all menu bars
  */
  public func quit() {
    for plugin in plugins {
      plugin.terminate()
    }
    tray.hide()
  }

  private func addPlugin(_ name: String, path: String) {
    switch fileFor(name: name) {
    case let Result.success(file, _):
      plugins.append(ExecutablePlugin(path: path, file: file, delegate: delegate))
    case let Result.failure(lines):
      let tray = Tray(title: "Loading...")
      let li = [
        "Invalid file name '\(path)'",
        "Should be on the form {name}.{number}{unit}.{ext}",
        "Eg. 'aFile.10d.sh'",
      ] + lines
      let title = Title(errors: li)
      title.applyTo(tray: tray)
      errors.append(tray)
    }
  }

  private func fileFor(name: String) -> Result<File> {
    return Pro.parse(Pro.getFile(), name)
  }

  /* TODO */
  func openReportIssuesPage() {
    // workspace.open(URL(string: "https://github.com/matryer/bitbar/issues")!)
  }

  func openPluginsBrowser() {
    // workspace.open(URL(string: "https://getbitbar.com/")!)
  }

  func openHomepage() {
    // workspace.open(URL(string: "https://github.com/matryer/bitbar")!)
  }

  func openPluginFolder() {
    // workspace.open(URL(fileURLWithPath: self.path))
  }

  func toggleOpen() {
    // launchAtLoginController.launchAtLogin = !launchAtLoginController.launchAtLogin
  }
}
