import AppKit
import Files
import Parser

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

class PluginManager: Parent {
  weak var root: Parent?
  private let tray = Tray(title: "BitBar", isVisible: false)
  private let path: String
  internal var pluginFiles = [PluginFile]() {
    didSet { verifyBar() }
  }

  /**
    Read plugins from @path
  */
  init(path: String) {
    self.path = path
    self.loadPlugins()
    self.verifyBar()
    self.tray.root = self
  }

  // Add plugin @name with @path to the list of plugins
  // Will fail with an error message if @name can't be parsed
  private func addPlugin(file: Files.File) {
    pluginFiles.append(PluginFile(file: file, delegate: self))
  }

  // Ensure atleast one icon is vissble in the menu bar
  private func verifyBar() {
    if pluginFiles.isEmpty {
      tray.show()
    } else {
      tray.hide()
    }
  }

  func plugins(byName name: String) -> [PluginFile] {
    return pluginFiles.filter { plugin in
      return NSPredicate(format: "name LIKE %@", name).evaluate(with: plugin)
    }
  }

  func refresh() {
    for pluginFile in pluginFiles {
      pluginFile.refresh()
    }
  }

  // Find all potential plugin files in {path}
  // and load them into BitBar
  private func loadPlugins() {
    do {
      for file in try Folder(path: path).files {
        if !file.name.hasPrefix(".") {
          addPlugin(file: file)
        }
      }
    } catch (let error) {
      tray.set(error: String(describing: error))
      tray.show()
    }
  }
}
