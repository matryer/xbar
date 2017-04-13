import Cocoa
import Async
import Foundation

final class Image: Param {
  var value: String { return escape(raw) }
  var attribute: String {
    if isTemplate { return "templateImage" }
    return "image"
  }
  let raw: String
  var isTemplate = false
  var priority = 0
  var values: [String: Any] {
    return ["data": raw, "isTemplate": isTemplate]
  }

  init(_ base64: String) {
    raw = base64
  }

  convenience init(_ base64: String, isTemplate: Bool) {
    self.init(base64)
    self.isTemplate = isTemplate
  }

  private func handleURL(url: URL, menu: Menuable) {
    menu.set(title: "…")
    Async.userInitiated {
      return url
    }.background { url in
      do {
        return try Data(contentsOf: url)
      } catch(_) {
        return nil
      }
    }.main { (input: Data?) in
      guard let data = input else { return }
      guard let image = NSImage(data: data) else { return }
      self.set(image: image, menu: menu)
    }
  }

  private func handleBase64(data: Data, menu: Menuable) {
    guard let image = NSImage(data: data) else {
      return menu.add(error: "Could not create image from '\(raw)'")
    }

    guard image.isValid else {
      return menu.add(error: "Image is not valid")
    }

    set(image: image, menu: menu)
  }

  private func set(image: NSImage, menu: Menuable) {
    menu.set(image: image, isTemplate: isTemplate)
  }

  func menu(didLoad menu: Menuable) {
    if let res = Data(base64Encoded: raw, options: Data.Base64DecodingOptions(rawValue: 0)) {
      handleBase64(data: res, menu: menu)
    } else if let url = URL(string: raw) {
      handleURL(url: url, menu: menu)
    } else {
      menu.add(error: "Image '\(raw)' is not valid")
    }
  }

  func equals(_ param: Param) -> Bool {
    if let image = param as? Image {
      if image.raw != raw { return false }
      return image.isTemplate == isTemplate
    }

    return false
  }
}
