import Parser

extension Parser.Image.Sort {
  var isTemplate: Bool {
    switch self {
    case .template:
      return true
    default:
      return false
    }
  }
}
