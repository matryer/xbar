public class ConfigHandler {
  private let global = GlobalConfig()
  private var plugins = [String: PluginConfig]()

  func add(env: String, value: String, to plugin: String) throws {
    if plugins[plugin] == nil {
      plugins[plugin] = PluginConfig()
    }

    try plugins[plugin]!.add(env: env, value: value)
  }

  func add(setting key: String, value: String, to pluginKey: String) throws {
    if plugins[pluginKey] == nil {
      plugins[pluginKey] = PluginConfig()
    }

    let plugin = plugins[pluginKey]!

    switch key {
    case "enabled":
      if let enabled = Bool(value) {
        try plugin.add(.enabled(enabled))
      } else {
        throw "cannot ready \(value) as a 'disabled' property"
      }
    default:
      throw "\(key) is not a valid global key"
    }
  }

  func add(global key: String, value: String) throws {
    switch key {
    case "port":
      if let port = Int(value) {
        try global.add(.port(port))
      } else {
        throw "cannot ready \(value) as a port number"
      }
    case "reloadOnConnection":
      if let bool = Bool(value) {
        try global.add(.reloadOnConnection(bool))
      } else {
        throw "Cannot read \(value) as bool for key reloadOnConnection"
      }
    default:
      throw "\(key) is not a valid global key"
    }
  }
}
