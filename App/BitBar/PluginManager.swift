import AppKit
import Swift
import Foundation
import Files
import Cent

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
  private let tray = Tray(title: "BitBar", isVisible: false)
  private let path: String
  private var errors = [Title]() {
    didSet { verifyBar() }
  }
  private var plugins = [Plugin]() {
    didSet { verifyBar() }
  }

  /**
    Read plugins from @path
  */
  init(path: String) {
    self.path = path
    self.loadPlugins()
    self.verifyBar()
  }

  /**
    Clean menu bar from error messages and plugins
  */
  func destroy() {
    tray.destroy()
    plugins.forEach { plugin in plugin.destroy() }
//    errors.forEach { tray in tray.destroy() }
    plugins = []
    errors = []
  }
  deinit { destroy() }

  // Add plugin @name with @path to the list of plugins
  // Will fail with an error message if @name can't be parsed
  private func addPlugin(_ name: String, path: String) {
    switch fileFor(name: name) {
    case let Result.success(file, _):
      plugins.append(ExecutablePlugin(path: path, file: file))
    case let Result.failure(lines):
      errors.append(Title(errors: [
        "An error occurred while reading file \(name) from \(path)",
        "\n",
        "Should be on the form {name}.{number}{unit}.{ext}, i.e 'aFile.10d.sh'",
        "Read the official documentation for more information",
        "Error message:\n"
      ] + lines))
    }
  }

  // Parse @name on form {name}.{number}{unit}.{ext}
  // I.e aFile.10d.sh
  private func fileFor(name: String) -> Result<File> {
    return Pro.parse(Pro.getFile(), name)
  }

  // Ensure atleast one icon is vissble in the menu bar
  private func verifyBar() {
    if errors.isEmpty && plugins.isEmpty {
      tray.show()
    } else {
      tray.hide()
    }
  }

  private func loadPlugins() {
    do {
      for file in try Folder(path: path).files {
        if !file.name.hasPrefix(".") {
          addPlugin(file.name, path: file.path)
        }
      }
    } catch (let error) {
      errors.append(Title(error: String(describing: error)))
    }
  }
}
