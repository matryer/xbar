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

  override func applyTo(menu: Menuable) {
    guard let unpacked = data else {
      return menu.add(error: "Could not unpack base64 image")
    }

    guard let image = NSImage(data: unpacked) else {
      return menu.add(error: "Could not create image from base64 string")
    }

    menu.update(image: image, isTemplate: isTemplate)
  }
}
