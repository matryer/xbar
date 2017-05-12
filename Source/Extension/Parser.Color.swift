import Parser
import Hue

extension Parser.Color {
  var nscolor: NSColor {
    switch self {
    case let .name(name):
      guard let hex = Color.names[name.lowercased()] else {
        // TODO: Handle missing color
        return using(hex: "ff4500")
      }
      return using(hex: hex)
    case let .hex(hex):
      return using(hex: hex)
    }
  }

  private func using(hex: String) -> NSColor {
    return NSColor(hex: "#" + hex)
  }
}
