import Parser

extension Parser.Image {
  var isTemplate: Bool {
    switch self {
    case let .base64(_, sort):
      return sort.isTemplate
    case let .href(_, sort):
      return sort.isTemplate
    }
  }

  var nsImage: NSImage? {
    switch self {
    case let .base64(string, sort):
      if let data = Data(base64Encoded: string) {
        return NSImage(data: data, isTemplate: sort.isTemplate)
      }
    default:
      return nil
    }

    return nil
  }
}
