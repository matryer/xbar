@testable import BitBar

extension File: Equatable {
  public static func == (_ a: File, _ b: File) -> Bool {
    return a.name == b.name && a.interval == b.interval && a.ext == b.ext
  }
}
