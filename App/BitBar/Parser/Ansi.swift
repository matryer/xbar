import Hue

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

  // Apply colors in @colors to @string
  func apply(_ string: String, _ colors: [Int]) -> Mutable {
    return colors.reduce(string.mutable()) {
      return $0.set(style: $1)
    }
  }

  // Check if @values contains @item
  func contains(_ values: [Int], _ item: Int) -> Bool {
    return values.reduce(false) { $0 || $1 == item }
  }

  func apply(_ ansis: [Any]) -> Mutable {
    return ansis.reduce(("".mutable(), [Int]())) { acc, value in
      switch value {
      case is String:
        acc.0.append(apply(value as! String, acc.1))
        return (acc.0, acc.1)
      case is [Int] where contains(value as! [Int], 0):
        return (acc.0, [])
      case is [Int]:
        return (acc.0, acc.1 + (value as! [Int]))
      default:
        preconditionFailure("Could not match against acc=\(acc), value=\(value)")
      }
    }.0
  }
}

private extension Mutable {
  // Add @style to attribute string
  // I.e 33 to make it green
  func set(style: Int) -> Mutable {
    guard let color = toColor(int: style) else {
      return self
    }

    return set(key: NSForegroundColorAttributeName, value: color)
  }

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
      preconditionFailure("Zero should not have come this far")
    default:
      return nil
    }
  }
}
