import AppKit

internal extension NSFont {
  func merge(_ font: NSFont) -> NSFont {
    return update(attributes: font.fontDescriptor.fontAttributes)
  }

  func update(size: Float) -> NSFont {
    return update(key: "NSFontSizeAttribute", value: CGFloat(size))
  }

  func update(name: String) -> NSFont {
    return update(attributes: ["NSFontNameAttribute": name])
  }

  func update(key: String, value: Any) -> NSFont {
    return update(attributes: [key: value])
  }

  func update(attributes: [String: Any]) -> NSFont {
    let desc = fontDescriptor.addingAttributes(attributes)
    // TODO: Don't use "!"
    return NSFont(descriptor: desc, textTransform: nil)!
  }
}
