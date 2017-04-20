import SwiftCheck
@testable import BitBar

extension Href: ParamBase {
  // TODO: Implement a more agressive generator
  private static let urls: Gen<URL> = lower.map { domain in
    return URL(string: "http://\(String(domain)).com/a/b/c")!
  }

  public static var arbitrary: Gen<Href> {
    return Gen.compose { c in
      Href(c.generate(using: urls))
    }
  }
}
