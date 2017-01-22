import Cocoa

protocol Menuable: MenuDelegate {
  var aTitle: NSMutableAttributedString { get set }
  var image: NSImage? { get set }
}

extension Menuable {
  func set(title: NSMutableAttributedString) {
    aTitle = title
  }

  /**
    Replace current title with @attr
    // TODO: Remove. Should be called update, not set
  */
  func update(title: String) {
    update(attr: NSMutableAttributedString(string: title))
  }

  // TODO: Rename to set
  func update(attr: NSMutableAttributedString) {
    set(title: aTitle.merge(attr))
  }

  func update(attrs: [String: Any]) {
    set(title: aTitle.update(attr: attrs))
  }

  /**
    Display an @image instead of text
  */
  func update(image anImage: NSImage, isTemplate: Bool = false) {
    image = anImage
    image?.isTemplate = isTemplate
  }

  /**
    Set the font size to @size
  */
  func update(size: Float) {
    set(title: aTitle.update(fontSize: size))
  }

  /**
    Use @color for the enture title
  */
  func update(color: NSColor) {
    update(key: NSForegroundColorAttributeName, value: color)
  }

  func update(key: String, value: Any) {
    update(attrs: [key: value])
  }

  func getAttrs() -> NSMutableAttributedString {
    return aTitle
  }

  /**
    Use @fontName, i.e Times-Roman
  */
  func update(fontName: String) {
    set(title: aTitle.update(fontName: fontName))
  }
}
