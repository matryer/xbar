import Vapor
import SwiftyTimer
import Foundation
import SwiftyBeaver
import Async

private func ok(_ msg: String) throws -> JSON {
  return try JSON(node: ["message": msg])
}

func startServer() throws -> Droplet {
  let manager = PluginManager.instance
  var config = try Config()
  try config.set("server.port", App.port)
  try config.set("server.hostname", "127.0.0.1")

  let drop = try Droplet(config)
  let log = SwiftyBeaver.self
  log.addDestination(FileDestination())
  log.addDestination(ConsoleDestination())

  drop.group("plugins") { group in
    // PATCH /plugins/refresh
    group.patch("refresh") { _ in
      manager.refresh()
      return try ok("Plugin(s) has beeen refreshed")
    }

    // GET /plugins
    group.get { _ in
      return try JSON(node: manager.pluginsNames)
    }
  }

  // WS /log
  drop.socket("log") { _, ws in
    ws.setup()
  }

  drop.group("plugin", PluginFile.parameter) { plugin in
    // GET /plugin/:plugin
    plugin.get { req in
      return try req.parameters.next(PluginFile.self).makeJSON()
    }

    // PATCH /plugin/:plugin/hide
    plugin.patch("hide") { req in
      try req.parameters.next(PluginFile.self).hide()
      return try ok("Plugin is now hidden")
    }

    // PATCH /plugin/:plugin/show
    plugin.patch("show") { req in
      try req.parameters.next(PluginFile.self).show()
      return try ok("Plugin is now visible")
    }

    // PATCH /plugin/:plugin/refresh
    plugin.patch("refresh") { req in
      try req.parameters.next(PluginFile.self).refresh()
      return try ok("Plugin is now refreshed")
    }

    // PATCH /plugin/:plugin/invoke/arg1/arg2
    plugin.patch("invoke", "*") { req in
      let plugin = try req.parameters.next(PluginFile.self)
      let args = req.uri.path.split("invoke/").last!.split("/")
      plugin.invoke(args)
      return try ok("Plugin has been invoked with passed args")
    }
  }

  return drop.start()
}
