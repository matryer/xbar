import Hue
import AppKit

typealias Value = (String, [Code])

final class Ansi: BoolVal, Param {
  var priority = 5
  var active: Bool { return bool }

  func menu(didLoad menu: Menuable) {
    guard active else { return }
    switch Pro.parse(Pro.getANSIs(), menu.getTitle()) {
    case let Result.success(result, _):
      menu.set(title: apply(result))
    case let Result.failure(lines):
      for error in lines {
        menu.add(error: error)
      }
    }
  }

  // Apply colors in @colors to @string
  private func apply(_ attrs: [Value]) -> Mutable {
    return attrs.reduce("".mutable()) { acc, attr in
      return acc.appended(attr.1.reduce(attr.0.mutable()) { mutable, code in
        switch code {
        case .underline(true):
          return mutable.style(with: .underline)
        case .strikethrough(true):
          return mutable.style(with: .strikethrough)
        case .bold(true):
          return mutable.style(with: .bold)
        case .italic(true):
          return mutable.style(with: .italic)
        case let .color(.background, color):
          return mutable.style(with: .background(color.toNSColor()))
        case let .color(.foreground, color):
          return mutable.style(with: .foreground(color.toNSColor()))
        default:
          print("Ignore \(code) for \(mutable)")
        }

        return mutable
      })
    }
  }

  private static func toFont(_ code: Int) -> FFont {
    switch code {
    case 0:
      return .default
    case 1...9:
      return .index(code)
    default:
      preconditionFailure("Invalid font code \(code)")
    }
  }

  private static func toColor(_ code: Int) -> CColor {
    switch code {
    case 0:
      return .black
    case 1:
      return .red
    case 2:
      return .green
    case 3:
      return .yellow
    case 4:
      return .blue
    case 5:
      return .magenta
    case 6:
      return .cyan
    case 7:
      return .white
    case 8:
      preconditionFailure("RGB requires more argument")
    default:
      preconditionFailure("Invalid color code \(code)")
    }
  }

  static func toCode(_ code: Int) -> Code? {
    switch code {
    case 0:
      return .reset(.all)
    case 1:
      return .bold(true) // 1=true, 22=false
    case 3:
      return .italic(true) // 3
    case 4:
      return .underline(true) // 4=true, 24=false
    case 5:
      return .blink(.slow)
    case 6:
      return .blink(.rapid) // .slow = 5, .rapid=5
    case 7:
      return .todo(7, "reverse")
    case 8: // 8
      return .todo(8, "conceal")
    case 9:
      return .strikethrough(true)
    case 10...19:
      return .font(toFont(code - 10))
    case 20:
      return .todo(20, "fraktur")
    case 21:
      return .bold(false)
    case 22:
      return .bold(false) // todo, no faint
    case 23:
      return .italic(false) // todo: no fraktur
    case 24:
      return .underline(false)
    case 25:
      return .blink(.none)
    case 26:
      return .todo(26, "reverse")
    case 27:
      return .todo(27, "positive image")
    case 28:
      return .todo(28, "conceal off")
    case 29:
      return .strikethrough(false)
    case 30...37:
      return .color(.foreground, toColor(code - 30))
    case 38:
      return nil
    case 39:
      return .reset(.foreground)
    case 40...47:
      return .color(.background, toColor(code - 40))
    case 48:
      return nil
    case 49:
      return .reset(.background)
    default:
      return .todo(code, "no name")
    }
  }

  static func toAttr(values: [Attributed]) -> [Value] {
    return values.reduce(([Value](), [Code]())) { (acc, value) in
      switch value {
      case let .string(string):
        return (acc.0 + [(string, acc.1)], acc.1)
      case let .codes(codes):
        return (acc.0, merge(codes: codes, with: acc.1))
      }
    }.0
  }

  static func merge(codes: [Code], with: [Code]) -> [Code] {
    return codes.reduce(with) { acc, code in
      switch code {
      case .reset(.all):
        return []
      case let .reset(location):
        return remove(location, from: acc)
      case let .color(location, color):
        return add(color: color, as: location, to: acc)
      default:
        return replace(item: code, from: acc)
      }
    }
  }

  static func add(color color1: CColor, as location1: Where, to codes: [Code]) -> [Code] {
    return codes.reduce([.color(location1, color1)]) { acc, code in
      switch code {
      case let .color(location2, _) where location1 == location2:
        return acc
      default:
        return acc + [code]
      }
    }
  }

  static func replace(item: Code, from codes: [Code]) -> [Code] {
    return codes.reduce([]) { acc, code in
      switch (code, item) {
      case (.blink(_), .blink(_)):
        return acc
      case (.italic(_), .italic(_)):
        return acc
      case (.underline(_), .underline(_)):
        return acc
      case (.bold(_), .bold(_)):
        return acc
      case (.strikethrough(_), .strikethrough(_)):
        return acc
      default:
        return acc + [code]
      }
    } + [item]
  }

  static func remove(_ location: Where, from codes: [Code]) -> [Code] {
    return codes.reduce([]) { acc, code in
      switch (code, location) {
      case (.color(.background, _), .background):
        return acc
      case (.color(.foreground, _), .foreground):
        return acc
      case (.color(_, _), .all):
        return []
      default:
        return acc + [code]
      }
    }
  }
}

enum Attributed {
  case codes([Code])
  case string(String)
}

enum Speed: Equatable {
  case slow
  case rapid
  case none

  public static func == (lhs: Speed, rhs: Speed) -> Bool {
    return String(describing: lhs) == String(describing: rhs)
  }
}

enum CColor: Equatable {
  case black // 0
  case red // 1
  case green // 2
  case yellow // 3
  case blue // 4
  case magenta // 5
  case cyan // 6
  case white // 7
  case rgb(Int, Int, Int) // 48, 38
  case index(Int)
  case `default`

  func toNSColor() -> NSColor {
    switch self {
    case .red:
      return NSColor(hex: "#ff0000")
    case .white:
      return NSColor(hex: "#ffffff")
    case .black:
      return NSColor(hex: "#000000")
    case .blue:
      return NSColor(hex: "#0000ff")
    case .green:
      return NSColor(hex: "#00ff00")
    case .yellow:
      return NSColor(hex: "#ffff00")
    case let .rgb(red, green, blue):
      let r1 = String(format: "%2X", red)
      let g1 = String(format: "%2X", green)
      let b1 = String(format: "%2X", blue)
      return NSColor(hex: "#" + r1 + g1 + b1)
    case let .index(color):
      let int = String(format: "%2X", color)
      return NSColor(hex: "#" + int)
    case .default:
      // TODO: What's the default color?
      return NSColor(hex: "#000000")
    default:
      /* TODO ... */
      return NSColor(hex: "#000000")
    }
  }

  public static func == (lhs: CColor, rhs: CColor) -> Bool {
    switch (lhs, rhs) {
    case (let .rgb(r1, g1, b1), let .rgb(r2, g2, b2)):
      return r1 == r2 && g1 == g2 && b1 == b2
    case (let .index(i1), let .index(i2)):
      return i1 == i2
    default:
      return String(describing: lhs) == String(describing: rhs)
    }
  }
}

// Ansi table= https://en.wikipedia.org/wiki/ANSI_escape_code
enum Code: Equatable {
  case reset(Where)
  case bold(Bool)
  case italic(Bool)
  case underline(Bool)
  case blink(Speed)
  case conceal
  case crossedOut
  case font(FFont)
  case fraktur
  case doubleUnderline
  case strikethrough(Bool)
  case normal
  case image
  case reveal
  case color(Where, CColor)
  case `default`(Where)
  case todo(Int, String)
  static func == (lhs: Code, rhs: Code) -> Bool {
    return String(describing: lhs) == String(describing: rhs)
  }
}

enum Where: Equatable {
  case background
  case foreground
  case all // TODO: Rename to both

  static func == (lhs: Where, rhs: Where) -> Bool {
    return String(describing: lhs) == String(describing: rhs)
  }
}

// TODO: Rename
enum FFont {
  case `default`
  case index(Int)
}
