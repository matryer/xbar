import SwiftyJSON
import Files

final class Emojize: BoolVal, Param {
  private static let jsonEmojize = File.from(resource: "emoji.json")
  private static let parser = Pro.replaceEmojize(replace: forChar)
  private static let emojis = readEmojize()

  var priority = 9
  var active: Bool { return bool }

  func menu(didLoad menu: Menuable) {
    guard active else { return }
    switch Pro.parse(Emojize.parser, menu.getTitle()) {
    case let Result.success(title, _):
      menu.update(title: title)
    case let Result.failure(lines):
      menu.add(error: "Failed to parse emojis")
      for error in lines {
        menu.add(error: error)
      }
    }
  }

  private static func forChar(_ char: String) -> String? {
    guard let hex = emojis[char] else {
      return nil
    }

    guard let int = Int(hex, radix: 16) else {
      return nil
    }

    guard let unicode = UnicodeScalar(int) else {
      return nil
    }

    return String(describing: unicode)
  }

  private static func read() -> Data? {
    do {
      return try Files.File(path: jsonEmojize).read()
    } catch {
      return nil
    }
  }

  private static func readEmojize() -> [String: String] {
    guard let data = read() else {
      return [:]
    }

    let emojis = JSON(data: data)
    var replacements = [String: String]()
    
    for emojize in emojis.arrayValue {
      for name in emojize["short_names"].arrayValue {
        guard let char = emojize["unified"].string else {
          continue
        }

        if let key = name.string {
          replacements[key] = char
        }
      }
    }
    return replacements
  }
}
