import Hue
typealias Stringish = NSMutableAttributedString

/* TODO: Use Extensions/NSMutableAttributedString.swift */
final class Ansi: BoolVal, Param {
  var priority: Int { return 5 }

  func applyTo(menu: Menuable) {
    guard getValue() else { return }

    switch Pro.parse(Pro.getANSIs(), menu.getTitle()) {
    case let Result.success(result, _):
      menu.update(attr: apply(result))
    case let Result.failure(lines):
      for error in lines {
        menu.add(error: error)
      }
    }
  }

  func new(string: String) -> Stringish {
    return Stringish(string: string, attributes: [:])
  }

  func empty() -> Stringish {
    return new(string: "")
  }

  func merge(_ attrs: [Stringish]) -> Stringish {
    let base = empty()

    for attr in attrs {
      base.append(attr)
    }

    return base
  }

  // TODO: Simplify algorithm
  func apply(_ ansis: [Any]) -> Stringish {
    var actions = [Action]()
    var values = [Stringish]()
    for ansi in ansis {
      switch ansi {
      case is [Int]:
        if let ids = ansi as? [Int] {
          for id in ids {
            if id == 0 {
              actions = []
            } else {
              actions.append(Action(id))
            }
          }
        }
      case is String:
        if let string = ansi as? String {
          values.append(apply(new(string: string), actions))
        }
      default:
        print("error: BUG!")
      }
    }

    return merge(values)
  }

  func apply(_ stringish: Stringish, _ actions: [Action]) -> Stringish {
    for action in actions { action.perform(stringish) }
    return stringish
  }
}

class Action {
  let idd: Int
  init(_ id: Int) {
    self.idd = id
  }

  func perform(_ stringish: Stringish) {
    guard let color = getColor() else {
      return
    }

    stringish.addAttribute(
      NSForegroundColorAttributeName,
      value: color,
      range: NSRange(location: 0, length: stringish.length)
    )
  }

  private func getColor() -> NSColor? {
    switch idd {
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
}
