//import Async
//import Foundation
//
//final class URLImage {
//  override var original: String {
//    return value.absoluteString
//  }
//
//  internal override func menu(didLoad menu: Menuable) {
//    menu.set(headline: "…") /* Loading message */
//
//    Async.userInitiated {
//      return self.value
//    }.background { url -> Data? in
//      do {
//        return try Data(contentsOf: url)
//      } catch(_) {
//        return nil
//      }
//    }.main { input -> Void in
//      guard let data = input else {
//        return menu.add(error: "Could not load image from url \(self.output)")
//      }
//
//      guard let image = NSImage(data: data) else {
//        return menu.add(error: "Data from url \(self.output) is not an image")
//      }
//
//      menu.set(image: image, isTemplate: self.isTemplate)
//    }
//  }
//}
