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

    for plugin in manager.plugins(byName: name) {
      plugin.refresh()
    }
  }
}
