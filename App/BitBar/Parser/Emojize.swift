import SwiftyJSON
import Files

extension String {
  var emojis: String {
    switch Pro.parse(Emojize.parser, self) {
    case let Result.success(title, _):
      return title
    case let Result.failure(lines):
      preconditionFailure("Error: \(lines)")
    }
  }
}

final class Emojize: BoolVal, Param {
  private static let jsonEmojize = File.from(resource: "emoji.json")
  static let parser = Pro.replaceEmojize(replace: forChar)
  private static let emojis = readEmojize()

  var priority = 15
  var active: Bool { return bool }

  func menu(didLoad menu: Menuable) {
    menu.update(title: menu.getTitle().emojis)
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
