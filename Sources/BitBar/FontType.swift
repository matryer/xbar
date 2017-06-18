import AppKit

enum FontType: String {
  case bar
  case item
  var font: NSFont {
    switch self {
    case .bar:
      return NSFont.menuBarFont(ofSize: 0)
    case .item:
      return NSFont.menuFont(ofSize: 0)
    }
  }

  var size: Float {
    return Float(font.pointSize)
  }
}
