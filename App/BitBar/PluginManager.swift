import AppKit
import Swift
import Foundation
import Files

/**
  The PluginManager is responsible for
    1. Reading all files from @path as plugins
    2. Displaying a default message in the menu bar if no plugins were found
    3. Parsing the file name for each potential plugin to determine
      if it contains the correct meta data, i.e aFile.10d.sh
        1. File name
        2. Update sequence
        3. File ending
    4. Notifying the TrayDelegate if a plugin closes
*/
class PluginManager {
  private let tray: Tray
  private let path: String
  private var errors = [Tray]()
  private var plugins = [Plugin]()
  private var delegate: TrayDelegate

  /**
    Reads plugins from @path and send notifications back to @delegate
  */
  init(path: String, delegate: TrayDelegate) {
    self.tray = Tray(title: "BitBar", delegate: delegate)
    self.delegate = delegate
    self.path = path
    setPlugins()
  }

  /**
    Quit any current running background tasks and removes all menu items
  */
  public func quit() {
    plugins.forEach { $0.terminate() }
    errors.forEach { $0.hide() }
    tray.hide()
    plugins = []
    errors = []
  }

  private func addPlugin(_ name: String, path: String) {
    // TODO: Clean up this mess :)
    switch fileFor(name: name) {
    case let Result.success(file, _):
      plugins.append(ExecutablePlugin(path: path, file: file, delegate: delegate))
    case let Result.failure(lines):
      let tray = Tray(title: "Loading...", delegate: delegate)
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
}
