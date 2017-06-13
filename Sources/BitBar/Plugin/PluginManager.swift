import AppKit
import Files
import Async
import Parser
import SwiftyBeaver

class PluginManager: Parent {
  internal static let instance = PluginManager()
  internal weak var root: Parent?
  internal let log = SwiftyBeaver.self
  private let tray = Tray(title: "BitBar", isVisible: true)
  private var path: String?
  internal var pluginFiles = [PluginFile]() {
    didSet { verifyBar() }
  }

  /**
    Read plugins from @path
  */
  init() {
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
    pluginFiles = []
    loadPlugins()
  }

  func findPlugin(byName name: String) -> PluginFile? {
    return plugins(byName: name).get(index: 0)
  }

  var pluginsNames: [String] {
    return pluginFiles.map { $0.name }
  }

  func set(path: String) {
    self.path = path
    pluginFiles = []
    loadPlugins()
  }

  // Find all potential plugin files in {path}
  // and load them into BitBar
  private func loadPlugins() {
    guard let folder = pluginFolder else {
      return set(error: "Could not load plugin folder")
    }

    if folder.files.count == 0 {
      return set(error: "No files found in plugin folder \(path ?? "<?>")")
    }

    for file in folder.files {
      if !file.name.hasPrefix(".") {
        self.addPlugin(file: file)
      }
    }
  }

  private var pluginFolder: Folder? {
    guard let pluginPath = path else {
      return nil
    }

    do {
      return try Folder(path: pluginPath)
    } catch {
      return nil
    }
  }

  private func err(_ msg: String) {
    log.error(msg)
  }

  private func set(error message: String) {
    /* TODO: Display error message to user */
    tray.set(error: true)
    tray.show()
    err(message)
  }
}
