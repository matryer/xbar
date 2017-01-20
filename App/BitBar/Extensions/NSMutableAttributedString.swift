import AppKit
typealias Mutable = NSMutableAttributedString

internal extension Mutable {
  convenience init(withDefaultFont string: String) {
    let aFont = NSFont.menuBarFont(ofSize: NSFont.systemFontSize())
    self.init(string: string, attributes: [NSFontAttributeName: aFont])
  }

  func update(font: NSFont) -> Mutable {
    let newFont = currentFont().merge(font)
    if let range = toRange() {
      addAttribute(NSFontAttributeName, value: newFont, range: range)
    }
    return self
  }

  func update(fontName: String) -> Mutable {
    return update(font: currentFont().update(name: fontName))
  }

  func update(fontSize: Float) -> Mutable {
    return update(font: currentFont().update(size: fontSize))
  }

  func update(attr: [String: Any]) -> Mutable {
    if let range = toRange() {
      addAttributes(attr, range: range)
    }

    return self
  }

  func merge(_ attr: Mutable) -> Mutable {
    return attr.update(attr: [NSFontAttributeName: currentFont()])
  }

  func truncate(_ maxLength: Int, suffix: String = "…") -> Mutable {
    guard let range = toRange(startIndex: maxLength) else {
      return self
    }

    return delete(inRange: range).append(suffix)
  }

  func append(_ suffix: String) -> Mutable {
    append(Mutable(withDefaultFont: suffix))
    return self
  }

  func delete(inRange range: NSRange) -> Mutable {
    deleteCharacters(in: range)
    return self
  }

  var count: Int {
    return length
  }

  func toRange(startIndex index: Int = 0) -> NSRange? {
    let offset = max(0, length - index)
    guard offset > 0  else {
      return nil
    }
    return NSRange(location: index, length: offset)
  }

  private func currentFont() -> NSFont {
    let defaultFont = NSFont.menuBarFont(ofSize: NSFont.systemFontSize())
    guard let range = toRange() else {
      return defaultFont
    }

    let attr = fontAttributes(in: range)
    guard let maybeFont = attr[NSFontAttributeName] else {
      return defaultFont
    }

    guard let font = maybeFont as? NSFont else {
      return defaultFont
    }

    return font
  }
}
