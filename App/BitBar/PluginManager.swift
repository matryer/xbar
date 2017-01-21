import AppKit
import Swift
import Foundation
import Files

class PluginManager: Base {
  let path: String
  let tray = Tray(title: "BitBar")
  var errors = [Tray]()
  var plugins = [Plugin]()

  init(path: String, delegate: AppDelegate?) {
    tray.delegate = delegate
    self.path = path
    super.init()
    setPlugins()
  }

  private func setPlugins() {
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
    plugins.forEach { $0.terminate() }
    errors.forEach { $0.hide() }
    tray.hide()
    plugins = []
    errors = []
  }

  private func addPlugin(_ name: String, path: String) {
    switch fileFor(name: name) {
    case let Result.success(file, _):
      plugins.append(ExecutablePlugin(path: path, file: file, delegate: tray.delegate))
    case let Result.failure(lines):
      let tray = Tray(title: "Loading...")
      let li = [
        "Invalid file name '\(path)'",
        "Should be on the form {name}.{number}{unit}.{ext}",
        "Eg. 'aFile.10d.sh'",
      ] + lines
      let title = Title(errors: li)
      tray.delegate = self.tray.delegate
      title.applyTo(tray: tray)
      errors.append(tray)
    }
  }

  private func fileFor(name: String) -> Result<File> {
    return Pro.parse(Pro.getFile(), name)
  }
}
