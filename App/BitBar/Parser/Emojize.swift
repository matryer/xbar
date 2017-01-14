import SwiftyJSON

final class Emojize: BoolVal {
  static var json = toJSON()

  override func applyTo(menu: MenuDelegate) {
    guard getValue() else {
      return print("Emojize has been turned off")
    }

    let parser = Pro.replaceEmojize {
      guard let hex = Emojize.json[$0] else {
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

    switch Pro.parse(parser, menu.title) {
    case let Result.success(title, _):
      menu.update(title: title)
    case let Result.failure(error):
      print("Could not parse emojize")
      print(error.joined(separator: "\n"))
    }
  }

  private static func toJSON() -> [String: String] {
    guard let data = NSData(contentsOfFile: jsonEmojize) else {
      return [:]
    }

    let json = JSON(data: data as Data)
    var result = [String: String]()
    for emojize in json.arrayValue {
      for name in emojize["short_names"].arrayValue {
          result[name.string!] = emojize["unified"].string!
      }
    }
    return result
  }
}
