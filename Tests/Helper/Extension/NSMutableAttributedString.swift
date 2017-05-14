import AppKit

enum Style {
  case strikethrough
  case bold
  case italic
  case underline
  case background(NSColor)
  case foreground(NSColor)
}

extension NSMutableAttributedString {
  var isBold: Bool {
    return traitSet?.contains(.boldFontMask) ?? false
  }

  var isItalic: Bool {
    return traitSet?.contains(.italicFontMask) ?? false
  }

  var fontSize: Int? {
    if let aFont = font {
      return Int(aFont.pointSize)
    }
    return nil
  }

  var fontName: String? {
    return font?.fontName
  }

  var hasUnderline: Bool {
    return has(key: NSUnderlineStyleAttributeName)
  }

  var isStrikeThrough: Bool {
    return has(key: NSStrikethroughStyleAttributeName)
  }

  var count: Int {
    return length
  }

  var isEmpty: Bool {
    return count == 0
  }

  func has(foreground color: NSColor) -> Bool {
    guard let maybe = get(key: NSForegroundColorAttributeName) else {
      return false
    }

    if let aColor = maybe as? NSColor {
      return color == aColor
    }

    return false
  }

  /**
    Does @self contain a background with color?
    TODO:; Why is this not tested?
    FIXME: This should return a static enum, not Bool
  */
  func has(background color: NSColor) -> Bool {
    guard let maybe = get(key: NSBackgroundColorAttributeName) else {
      return false
    }

    if let aColor = maybe as? NSColor {
      return color == aColor
    }

    return false
  }

  func toRange(startIndex index: Int = 0) -> NSRange? {
    let offset = Swift.max(0, length - index)
    guard offset > 0  else {
      return nil
    }

    return NSRange(location: index, length: offset)
  }

  var font: NSFont? {
    guard let range = toRange() else {
      return nil
    }

    let attr = fontAttributes(in: range)
    guard let maybeFont = attr[NSFontAttributeName] else {
      return nil
    }

    guard let font = maybeFont as? NSFont else {
      return nil
    }

    return font
  }

  private var traitSet: NSFontTraitMask? {
    guard let aFont = font else {
      return nil
    }
    let descriptor = aFont.fontDescriptor
    let symTraits = descriptor.symbolicTraits
    return NSFontTraitMask(rawValue: UInt(symTraits))
  }

  private func get(key: String) -> Any? {
    if string.isEmpty { return nil }
    return attributes(at: 0, effectiveRange: nil)[key]
  }

  private func has(key: String) -> Bool {
    guard let _ = get(key: key) else {
      return false
    }

    return true
  }
}
