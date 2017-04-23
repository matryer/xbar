import Foundation

class Param<T>: Paramable {
  var value: T
  var before: Filter { return [] }
  var after: Filter { return [] }
  var original: String { return raw }
  var raw: String { return String(describing: value) }
  var key: String {
    return String(describing: type(of: self)).camelCase
  }

  init(_ value: T) {
    self.value = value
  }

  func menu(didClick: Menuable) {}
  func menu(didLoad: Menuable) {}
  func menu(didClick menu: Menuable, done: @escaping (String?) -> Void) { done(nil) }

  func escape(_ value: String, quote: String = "\"") -> String {
    return quote + value.replace("\\", "\\\\").replace(quote, "\\" + quote) + quote
  }
}
