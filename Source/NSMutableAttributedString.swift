import Attr
typealias Mutable = NSMutableAttributedString

extension Mutable {
  func background(color: CColor) -> Mutable {
    return style(with: .background(color.toNSColor()))
  }

  func foreground(color: CColor) -> Mutable {
    return style(with: .foreground(color.toNSColor()))
  }
}
