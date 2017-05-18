import Parser
import BonMot
import Cent
import Ansi
import Emojize
import Foundation

extension Parser.Text {
  private func font(withBase base: NSFont) -> NSFont? {
    guard let font = self.font else {
      return base
    }
    
    switch font {
    case let .font(name, size):
      return NSFont(name: name, size: CGFloat(size))
    case let .size(size):
      return NSFont(name: base.fontName, size: CGFloat(size))
    case let .name(name):
      return NSFont(name: name, size: base.pointSize)
    }
  }

  private var params: [Parser.Text.Param] {
    switch self {
    case let .normal(_, params):
      return params
    }
  }

  private var font: Parser.Font? {
    for case let .font(font) in params {
      return font
    }
    
    return nil
  }

  private var title: String {
    switch self {
    case let .normal(title, _):
      return title
    }
  }

  private var cleanTitle: String {
    return params.reduce(title) { title, param in
      switch param {
      case let .length(value):
        return title.truncated([value - 1, 0].max()!)
      case .emojize:
        return title.emojified
      case .trim:
        return title.trimmed()
      default:
        return title
      }
    }
  }

  private var endState: [StringStyle.Part] {
    return params.reduce([]) { acc, param in
      switch param {
      case let .color(color):
        return acc + [.color(color.nscolor)]
      default:
        return acc
      }
    }
  }

  private func use(font: NSFont) -> Immutable {
    if params.has(.ansi) {
      do {
        return try cleanTitle.ansified(using: font).styled(with: StringStyle(endState))
      } catch let error {
        print("[Error] Could not parse ansi: \(String(describing: error))")
        return cleanTitle.styled(with: StringStyle(endState))
      }
    } else {
      return cleanTitle.styled(with: StringStyle([.font(font)] + endState))
    }
  }

  func colorize(as type: FontType) -> Immutable {
    if let aFont = font(withBase: type.font) {
      return use(font: aFont)
    } else {
      return use(font: type.font)
    }
  }
}
