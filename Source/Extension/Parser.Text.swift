import Parser
import Emojize

extension Parser.Text {
  private var initValue: Mutable {
    switch self {
    case let .normal(title, params):
      if params.has(.ansi) {
        return Ansi.app(title).mutable()
      }

      return title.mutable()
    }
  }

  var colorize: Mutable {
    switch self {
    case let .normal(_, params):
      return params.sorted().reduce(initValue) { title, param in
        switch param {
        case let .color(color):
          return title.style(with: .foreground(color.nscolor))
        case let .font(name):
          return title.update(fontName: name)
        case let .length(value):
          return title.truncate([value - 1, 0].max()!)
        case let .size(value):
          return title.update(fontSize: value)
        case .emojize:
          return title.emojified.mutable()
        case .ansi:
          return title
        case .trim:
          return title.trimmed()
        }
      }
    }
  }
}
