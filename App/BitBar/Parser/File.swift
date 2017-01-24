import Cocoa

class File {
  let name: String
  let interval: Int
  let ext: String

  init(_ name: String, _ interval: Int, _ ext: String) {
    self.name = name
    self.interval = interval
    self.ext = ext
  }

  static public func join(_ paths: String...) -> String {
    if paths.isEmpty { fatalError("Min 1 path, got zero") }
    if paths.count == 1 { return paths[0] }
    return paths[1..<paths.count].reduce(paths[0]) {
      URL(fileURLWithPath: $0).appendingPathComponent($1).path
    } as String
  }

  static var resourcesPath: String {
    return Bundle.main.resourcePath!
  }

  static func from(resource file: String) -> String {
    return join(resourcesPath, file)
  }
}
