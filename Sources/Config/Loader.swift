//import Files
//import Foundation
//import INI
//
//let home = Folder.home
//let configFile = ".bitbarrc"
//let handler = ConfigHandler()
//
//public func loadConfigFile() throws -> ConfigHandler {
//  let bundle = Bundle(for: PluginConfig.self)
//  
//  guard let example = bundle.path(forResource: "bitbarrc", ofType: "ini") else {
//    throw "Could not load bitbarrc config from project"
//  }
//  
//  guard let data = try? File(path: example).read() else {
//    throw "Could not read content from \(example)"
//  }
//  
//  try home.createFileIfNeeded(withName: configFile, contents: data)
//  
//  let absoluteConfigPath = try home.file(named: configFile).path
//  let config = try parseINI(filename: absoluteConfigPath)
//  
//  for key in config.sections {
//    if key.name == "global" {
//      for (inner, value) in key.settings {
//        try handler.add(global: inner, value: value)
//      }
//    } else {
//      for (inner, value) in key.settings {
//        if inner.hasPrefix("env.") {
//          try handler.add(env: inner.split(".").last!, value: value, to: key.name)
//        } else {
//          try handler.add(setting: inner, value: value, to: key.name)
//        }
//      }
//    }
//  }
//  
//  return handler
//}
