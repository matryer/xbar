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
  let drop = try Droplet()
  let log = SwiftyBeaver.self

  log.addDestination(ConsoleDestination())

  drop.group("plugins") { group in
    group.patch("refresh") { _ in
      manager.refresh()
      return try ok("Plugin(s) has beeen refreshed")
    }

    group.get("") { _ in
      return try JSON(node: manager.pluginsNames)
    }
  }

  drop.socket("log") { _, ws in
    ws.setup()
  }

  drop.group("plugin", PluginFile.parameter) { plugin in
    plugin.get("") { req in
      return try req.parameters.next(PluginFile.self).makeJSON()
    }

    plugin.patch("hide") { req in
      try req.parameters.next(PluginFile.self).hide()
      return try ok("Plugin is now hidden")
    }

    plugin.patch("show") { req in
      try req.parameters.next(PluginFile.self).show()
      return try ok("Plugin is now visible")
    }

    plugin.patch("refresh") { req in
      try req.parameters.next(PluginFile.self).refresh()
      return try ok("Plugin is now refreshed")
    }

    plugin.patch("invoke", "*") { req in
      let plugin = try req.parameters.next(PluginFile.self)
      let args = req.uri.path.split("invoke/").last!.split("/")
      plugin.invoke(args)
      return try ok("Plugin has been invoked with passed args")
    }
  }

  return drop.start()
}
