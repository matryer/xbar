import Foundation
import Cocoa

class RefreshPluginHandler {
  private let manager: PluginManager
  private let queries: [String: String]

  init(_ queries: [String: String], manager: PluginManager) {
    self.queries = queries
    self.manager = manager
    handle()
  }

  private func handle() {
    guard let name = queries["name"] else {
      return print("[Error] Name not specified for refreshPlugin")
    }

    let plugins = manager.plugins.filter { plugin in
      return NSPredicate(format: "description LIKE %@", name).evaluate(with: plugin)
    }

    for plugin in plugins {
      plugin.refresh()
    }

    print("[Log] Found \(plugins.count) plugins to reload")
  }
}
