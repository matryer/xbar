import AppKit

final class Base64Image: Image<NSImage> {
  override func menu(didLoad menu: Menuable) {
    menu.set(image: value, isTemplate: isTemplate)
  }
}
