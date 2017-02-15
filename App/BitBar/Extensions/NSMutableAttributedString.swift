import AppKit
typealias Mutable = NSMutableAttributedString
private let manager = NSFontManager.shared()

extension Mutable {
  private static let defaultFont = NSFont.menuBarFont(ofSize: 0)
  enum Style {
    case strikethrough
    case bold
    case italic
    case underline
    case background(NSColor)
    case foreground(NSColor)
  }

  enum Ground {
    case foreground
    case background
  }

  convenience init(withDefaultFont string: String) {
    self.init(string: string, attributes: [NSFontAttributeName: Mutable.defaultFont])
  }

  static func + (left: Mutable, right: Mutable) -> Mutable {
    return left.appended(right)
  }

  var isBold: Bool {
    return traitSet.contains(.boldFontMask)
  }

  var isItalic: Bool {
    return traitSet.contains(.italicFontMask)
  }

  var fontSize: Int {
    return Int(font.pointSize)
  }

  var fontName: String {
    return font.fontName
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

  func update(font aFont: NSFont) -> Mutable {
    if let range = toRange() {
      addAttribute(NSFontAttributeName, value: font.merge(aFont), range: range)
    }
    return self
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

  /**
    Does @self contain a background / foreground?
  */
  func has(_ ground: Ground) -> Bool {
    switch ground {
    case .foreground:
      return has(key: NSForegroundColorAttributeName)
    case .background:
      return has(key: NSBackgroundColorAttributeName)
    }
  }

  /**
    Set style for @self. Overrides existing values for the same style
  */
  func style(with style: Style) -> Mutable {
    switch style {
    case .bold:
      return applyFontTraits(NSFontTraitMask.boldFontMask)
    case .italic:
      return applyFontTraits(NSFontTraitMask.italicFontMask)
    case .strikethrough:
      return update(attr: [
        NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
      ])
    case .underline:
      return update(attr: [
        NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
      ])
    case let .background(color):
      return update(attr: [NSBackgroundColorAttributeName: color])
    case let .foreground(color):
      return update(attr: [NSForegroundColorAttributeName: color])
    }
  }

  func background(color: CColor) -> Mutable {
    return style(with: .background(color.toNSColor()))
  }

  func foreground(color: CColor) -> Mutable {
    return style(with: .foreground(color.toNSColor()))
  }

  func update(fontName: String) -> Mutable {
    return update(attr: [NSFontAttributeName: manager.convert(font, toFamily: fontName)])
  }

  func update(fontSize: Float) -> Mutable {
    return update(attr: [NSFontAttributeName: manager.convert(font, toSize: CGFloat(fontSize))])
  }

  func update(attr: [String: Any]) -> Mutable {
    if let range = toRange() {
      addAttributes(attr, range: range)
    }

    return self
  }

  func set(key: String, value: Any) -> Mutable {
    return update(attr: [key: value])
  }

  func merge(_ attr: Mutable) -> Mutable {
    if attr.has(key: NSFontAttributeName) {
      return attr
    }

    return attr.update(attr: [NSFontAttributeName: font])
  }

  /**
    Shorten @self to the length passed. Prepends @suffix, if @self is truncated
  */
  func truncate(_ maxLength: Int, suffix: String = "…") -> Mutable {
    guard let range = toRange(startIndex: maxLength) else {
      return self
    }

    return delete(inRange: range).appended(string: suffix)
  }

  func appended(_ suffix: Mutable) -> Mutable {
    append(suffix)
    return self
  }

  func appended(string: String) -> Mutable {
    return appended(Mutable(withDefaultFont: string))
  }

  func trimmed() -> Mutable {
    let charSet = NSCharacterSet.whitespacesAndNewlines
    var range = (string as NSString).rangeOfCharacter(from: charSet)

    // Trim leading characters from character set.
    while range.length != 0 && range.location == 0 {
      deleteCharacters(in: range)
      range = (string as NSString).rangeOfCharacter(from: charSet)
    }

    // Trim trailing characters from character set.
    range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
    while range.length != 0 && NSMaxRange(range) == length {
      deleteCharacters(in: range)
      range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
    }

    return self
  }

  private func delete(inRange range: NSRange) -> Mutable {
      deleteCharacters(in: range)
    return self
  }

  func toRange(startIndex index: Int = 0) -> NSRange? {
    let offset = max(0, length - index)
    guard offset > 0  else {
      return nil
    }

    return NSRange(location: index, length: offset)
  }

  var font: NSFont {
    guard let range = toRange() else {
      return Mutable.defaultFont
    }

    let attr = fontAttributes(in: range)
    guard let maybeFont = attr[NSFontAttributeName] else {
      return NSMutableAttributedString.defaultFont
    }

    guard let font = maybeFont as? NSFont else {
      return NSMutableAttributedString.defaultFont
    }

    return font
  }

  private var traitSet: NSFontTraitMask {
    let descriptor = font.fontDescriptor
    let symTraits = descriptor.symbolicTraits
    return NSFontTraitMask(rawValue: UInt(symTraits))
  }

  private func applyFontTraits(_ mask: NSFontTraitMask) -> Mutable {
    let newFont = manager.convert(font, toHaveTrait: mask)
    if let range = toRange() {
      addAttribute(NSFontAttributeName, value: newFont, range: range)
    }

    return self
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
