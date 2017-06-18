import Foundation
import Cocoa
import SwiftyBeaver

class RefreshPluginHandler {
  private let manager: PluginManager
  private let queries: [String: String]
  private let log = SwiftyBeaver.self

  init(_ queries: [String: String], manager: PluginManager) {
    self.queries = queries
    self.manager = manager
    handle()
  }

  private func handle() {
    guard let name = queries["name"] else {
      return log.error("Name not specified for refreshPlugin")
    }

    for plugin in manager.plugins(byName: name) {
      plugin.refresh()
    }
  }
}
