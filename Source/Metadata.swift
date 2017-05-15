import FootlessParser
import Foundation
import Dollar

enum Metadata {
  private static let start = "<bitbar."
  internal static var parser: P<[Metadata]> {
    return zeroOrMore(til(start, consume: true) *> item)
  }

  private static var item: P<Metadata> {
    return(string(start) *> til(">")) >>- { type in
      return (til("<") <* til(">")) >>- { value in
        if let metadata = Metadata(key: type, value: value) {
          return pure(metadata)
        }
        return stop("Could not find any type matching \(type) & \(value)")
      }
    }
  }

  private static func til(_ value: String, consume: Bool = true) -> P<String> {
    let par = zeroOrMore(noneOf([value]))

    if consume {
      return par <* string(value)
    }

    return par
  }

  private static func stop<A, B>(_ message: String) -> Parser<A, B> {
    return Parser { parsedtokens in
      throw ParseError.Mismatch(parsedtokens, message, "done")
    }
  }

  case about(URL)
  case image(URL)
  case title(String)
  case github(String)
  case version(String)
  case description(URL)
  case dependencies([String])

  init?(key: String, value: String) {
    switch key.lowercased() {
    case "title":
      self = .title(value)
    case "version":
      self = .version(value)
    case "author":
      self = .github(value)
    case "description":
      if let url = URL(string: value) {
        self = .description(url)
      }
    case "image":
      if let url = URL(string: value) {
        self = .image(url)
      }
    case "dependencies":
      self = .dependencies(value.split(delimiter: ","))
    case "abouturl":
      if let url = URL(string: value) {
        self = .about(url)
      }
    default:
      return nil
    }
    return nil
  }
}
