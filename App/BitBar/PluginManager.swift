import AppKit
import Swift
import Foundation
import Async
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
  private let path: String
  private let tray = Tray(title: "BitBar")
  private var errors = [Title]() {
    didSet { verifyBar() }
  }
  private var plugins = [Plugin]() {
    didSet { verifyBar() }
  }

  /**
    Reads plugins from @path and send notifications back to @delegate
  */
  init(path: String) {
    self.path = path
    self.setPlugins()
    self.verifyBar()
  }

  /**
    Quit any current running background tasks and removes all menu items
  */
  deinit { destroy() }
  func destroy() {
    tray.destroy()
    plugins.forEach { plugin in plugin.destroy() }
    errors.forEach { tray in tray.destroy() }
  }

  private func addPlugin(_ name: String, path: String) {
    // TODO: Clean up this mess :)
    switch fileFor(name: name) {
    case let Result.success(file, _):
      plugins.append(ExecutablePlugin(path: path, file: file))
    case let Result.failure(lines):
      // let tray = Tray(title: "E", delegate: delegate)
      let li = [
        "Invalid file name '\(path)'",
        "Should be on the form {name}.{number}{unit}.{ext}",
        "Eg. 'aFile.10d.sh'"
      ] + lines
      // let title = Title(errors: li)
      // title.applyTo(tray: tray)
      errors.append(Title(errors: li))
    }
  }

  private func fileFor(name: String) -> Result<File> {
    return Pro.parse(Pro.getFile(), name)
  }

  private func verifyBar() {
    if errors.isEmpty && plugins.isEmpty {
      tray.show()
    } else {
      tray.hide()
    }
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
  }

  private func show(error: String) {
//    Title(errors: [error]).applyTo(tray: tray)
  }
}
