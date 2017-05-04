@testable import BitBarParser

extension Menu.Tail: CustomStringConvertible {
  public var description: String { return toString(0) }

  func toString(_ params: [Menu.Param], _ tails: [Menu.Tail], _ level: Int) -> String {
    let tail = tails.map { $0.toString(level + 1) }.joined()
    let param = " | " + params.map(String.init(describing:)).joined(separator: " ")
    switch (params.count, tails.count) {
    case (0, 0):
      return ""
    case (_, 0):
      return "\n" + tail
    case (0, _):
      return param + "\n"
    case (_, _):
      return param + "\n" + tail
    }
  }

  func indent(_ level: Int) -> String {
    return (0..<level).map { _ in "--" }.joined()
  }

  func toString(_ level: Int) -> String {
    switch self {
    case let .text(text, params, tails, _):
      return indent(level)
        + String(describing: text)
        + toString(params, tails, level)
    case .separator:
      return indent(level) + "[separator]\n"
    case let .image(image, params, tails, _) where tails.isEmpty:
      return indent(level)
        + "[image] | "
        + String(describing: image)
        + " "
        + params.map(String.init(describing:)).joined(separator: " ")
        + "\n"
    case let .image(image, params, tails, _):
      return indent(level)
        + "[image] | "
        + String(describing: image)
        + " "
        + params.map(String.init(describing:)).joined(separator: " ")
        + "\n"
        + tails.map { $0.toString(level + 1) }.joined()
    case let .error(messages):
      return indent(level)
        + "Found \(messages.count) errors\n"
        + messages.joined(separator: indent(level) + "\n")
        + "\n"
    }
  }
}
