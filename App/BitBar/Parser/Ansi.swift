import Hue


func toColor(int: Int) -> NSColor? {
  switch int {
  case 32:
    return NSColor(hex: "#00ff00")
  case 33:
    return NSColor(hex: "#ffff00")
  case 34:
    return NSColor(hex: "#5c5cff")
  case 31:
    return NSColor(hex: "#ff0000")
  case 0:
    return nil
  default:
    return nil
  }
}

extension Mutable {
  func set(style: Int) -> Mutable {
    guard let color = toColor(int: style) else {
      return self
    }

    return set(key: NSForegroundColorAttributeName, value: color)
  }
}

final class Ansi: BoolVal, Param {
  var priority = 5
  var active: Bool { return bool }

  func menu(didLoad menu: Menuable) {
    guard active else { return }

    switch Pro.parse(Pro.getANSIs(), menu.getTitle()) {
    case let Result.success(result, _):
      menu.update(attr: apply(result))
    case let Result.failure(lines):
      for error in lines {
        menu.add(error: error)
      }
    }
  }

  func apply(_ string: String, _ colors: [Int]) -> Mutable {
    return colors.reduce(string.mutable()) {
      return $0.set(style: $1)
    }
  }

  func contains(_ values: [Int], _ item: Int) -> Bool {
    return values.reduce(false) { $0 || $1 == item }
  }


  // ["ABC", [1,2], [1,2], "X"]
  func apply(_ ansis: [Any]) -> Mutable {
    let empty = "".mutable()
    let colors = [Int]()
    let result = ansis.reduce((empty, colors)) { input, value in
      let acc = input.0
      let colors = input.1
      switch value {
      case is String:
        acc.append(apply(value as! String, colors))
        return (acc, colors)
      case is [Int] where contains(value as! [Int], 0):
        return (acc, [])
      case is [Int]:
        return (acc, colors + (value as! [Int]))
      default:
        preconditionFailure("Could not match against colors=\(colors) acc=\(acc), value=\(value)")
      }
    }

    return result.0
  }
}
