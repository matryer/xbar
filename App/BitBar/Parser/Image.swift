import Cocoa

final class Image: StringVal {
  let data: Data?
  var isTemplate = false

  override init(_ base64: String) {
    self.data = Data(
      base64Encoded: base64,
      options: Data.Base64DecodingOptions(rawValue: 0)
    )
    super.init(base64)
  }

  convenience init(_ base64: String, isTemplate: Bool) {
    self.init(base64)
    self.isTemplate = isTemplate
  }

  override func applyTo(menu: MenuDelegate) {
    guard let unpacked = data else {
      // TODO: Better error handling
      return print("Could not load image")
    }

    guard let image = NSImage(data: unpacked) else {
      return print("Could not create image")
    }

    menu.update(image: image, isTemplate: isTemplate)
  }
}
