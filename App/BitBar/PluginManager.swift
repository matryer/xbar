import AppKit
import Swift
import Foundation

class PluginManager: Base, TrayDelegate {
  let path: String
  let workspace = NSWorkspace.shared
  var delegate: AppDelegate?
  var errors: [Tray] = []

  var isTerminated = false
  var plugins: [Plugin] = [] {
    didSet { delegate?.managerDidChangePlugins(plugins) }
  }

  init(path: String, delegate: AppDelegate?) {
    self.delegate = delegate
    self.path = path
    super.init()
    for file in getPluginFiles() {
      if file.hasPrefix(".") { continue }
      // TODO: join using something designed for paths
      addPlugin(file, path: [path, file].joined(separator: "/"))
    }
  }

  func refresh() {
    for error in errors { error.hide() }
    for plugin in plugins { plugin.refresh() }
    errors = []
  }

  func quit() {
    if isTerminated { return }
    for plugin in plugins { plugin.hide() }
    isTerminated = true
    delegate?.managerDidQuit()
  }

  /* Events */
  func pluginDidInvokeQuit(_ plugin: Plugin) {
    log("pluginDidInvokeQuit", "User clicked 'quit', terminating all plugins")
    quit()
  }

  func pluginDidInvokeRefreshAll(_ plugin: Plugin) {
    log("pluginDidInvokeRefresh", "User clicked 'refresh all', reloading all plugins")
    refresh()
  }

  func preferenceDidRefreshAll() {
    log("preferenceDidRefreshAll", "User clicked 'reload all' in pref menu")
    refresh()
  }

  func preferenceDidChangePluginFolder() {
    log("preferenceDidChangePluginFolder", "TODO")
  }

  func preferenceDidQuit() {
    log("preferenceDidQuit", "Plugin delegated 'quit' from pref menu")
    quit()
  }

  private func addPlugin(_ name: String, path: String) {
    switch fileFor(name: name) {
    case let Result.success(file, _):
      plugins.append(ExecutablePlugin(path: path, file: file, manager: self))
    case let Result.failure(error):
      errors.append(Tray(title: "ERROR: " + String(describing: error), isVisible: true))
    }
  }

  private func fileFor(name: String) -> Result<File> {
    return Pro.parse(Pro.getFile(), name)
  }

  fileprivate func getPluginFiles() -> [String] {
    print("Load plugins from", path)
    let fileManager = FileManager.default
    do {
      return try fileManager.contentsOfDirectory(atPath: path)
    } catch(_) {
      return []
    }
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
