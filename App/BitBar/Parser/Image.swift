import Cocoa

final class Image: Param {
  var value: String { return escape(raw) }
  var attribute: String {
    if isTemplate { return "templateImage" }
    return "image"
  }

  let data: Data?
  var isTemplate = false
  var priority = 0
  let raw: String
  var values: [String: Any] {
    return ["raw": raw, "isTemplate": isTemplate]
  }

  init(_ base64: String) {
    raw = base64
    self.data = Data(
      base64Encoded: base64,
      options: Data.Base64DecodingOptions(rawValue: 0)
    )
  }

  convenience init(_ base64: String, isTemplate: Bool) {
    self.init(base64)
    self.isTemplate = isTemplate
  }

  func menu(didLoad menu: Menuable) {
    guard let unpacked = data else {
      return menu.add(error: "Could not unpack base64 image from \(raw)")
    }

    guard let image = NSImage(data: unpacked) else {
      return menu.add(error: "Could not create image from \(unpacked)")
    }

    menu.update(image: image, isTemplate: isTemplate)
  }

  func equals(_ param: Param) -> Bool {
    if let image = param as? Image {
      if image.raw != raw { return false }
      return image.isTemplate == isTemplate
    }

    return false
  }
}
