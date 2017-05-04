import SwiftCheck
@testable import BitBarParser

extension Image: Arbable {
  static let b64 = ascii.map { $0.base64 }
  static let b1 = b64.map { Image.base64($0, true) }
  static let b2 = b64.map { Image.base64($0, false) }
  static let u1 = url.map { Image.href($0, true) }
  static let u2 = url.map { Image.href($0, false) }

  public static var arbitrary: Gen<Image> {
    return [b1, b2, u1, u2].one()
  }

  var output: String {
    switch self {
    case let .base64(data, true):
      return "templateImage=\(data.quoted())"
    case let .base64(data, false):
      return "image=\(data.quoted())"
    case let .href(url, true):
      return "templateImage=\(url.quoted())"
    case let .href(url, false):
      return "image=\(url.quoted())"
    }
  }

  public static func ==== (lhs: Image, rhs: Image) -> Property {
    switch (lhs, rhs) {
    case let (.base64(b1, s1), .base64(b2, s2)):
      return b1 ==== b2 ^&&^ s1 ==== s2
    case let (.href(h1, s1), .href(h2, s2)):
      return h1 ==== h2 ^&&^ s1 ==== s2
    default:
      return false <?> "image: \(lhs) != \(rhs)"
    }
  }
}
