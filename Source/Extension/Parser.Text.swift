import Parser
import BonMot
import Cent
import Ansi
import Emojize
import Foundation

import AppKit

enum Style {
  case strikethrough
  case bold
  case italic
  case underline
  case background(NSColor)
  case foreground(NSColor)
}

extension Mutable {
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

extension String {
  func truncated(_ length: Int, trailing: String = "…") -> String {
    if characters.count > length {
      return self[0..<length] + trailing
    } else {
      return self
    }
  }
}

extension Parser.Text {
  private func font(withBase base: NSFont) -> NSFont? {
    switch (fontName, fontSize) {
    case let (.some(name), .some(size)):
      return NSFont(name: name, size: CGFloat(size))
    case let (.none, .some(size)):
      return NSFont(name: base.fontName, size: CGFloat(size))
      // return NSFont.menuBarFont(ofSize: CGFloat(size))
    case let (.some(name), .none):
      return NSFont(name: name, size: base.pointSize)
    default:
      return base
    }
  }

  private var params: [Parser.Text.Param] {
    switch self {
    case let .normal(_, params):
      return params
    }
  }

  private var fontName: String? {
    return params.reduce(nil) { font, param in
      if (font != nil) { return font }
      switch param {
      case let .font(name):
        return name
      default:
        return font
      }
    }
  }

  private var fontSize: Float? {
    return params.reduce(nil) { size, param in
      if (size != nil) { return size }
      switch param {
      case let .size(value):
        return value
      default:
        return size
      }
    }
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
