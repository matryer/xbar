import SwiftCheck

extension String {
  static func any(min: Int, max: Int) -> Gen<String> {
    return Character.arbitrary.proliferateRange(min, max).map { String($0) }
  }

  static func any(min: Int) -> Gen<String> {
    return Character.arbitrary.map { String($0) }.suchThat { $0.characters.count >= min }
  }

  static func any(empty: Bool = false) -> Gen<String> {
    if empty { return Character.arbitrary.map { String($0) } }
    return Character.arbitrary.proliferateNonEmpty.map { String($0) }
  }

  func escaped(_ chars: [String] = []) -> String {
    return (["\\"] + chars).reduce(self) { $0.replace($1, "\\" + $1) }
  }

  func quoted(_ quote: String = "\"") -> String {
    return quote + escaped(["\""]) + quote
  }

  func titled() -> String {
    return escaped(["|", "\n"])
  }

  func replace(_ what: String, _ with: String) -> String {
    return replacingOccurrences(of: what, with: with, options: .literal, range: nil)
  }

  func inspected() -> String {
    return "\"" + replace("\n", "↵").replace("\0", "0") + "\""
  }

  var base64: String {
    return Data(self.utf8).base64EncodedString()
  }
}
