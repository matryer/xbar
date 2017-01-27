import Foundation

final class Href: Param {
  var priority = 0
  var value: String { return raw }
  var url: URL?
  var raw: String
  var values: [String: Any] {
    return ["url": url ?? "url", "raw": raw]
  }

  init(_ url: String) {
    self.url = URL(string: url)
    self.raw = url
  }

  func menu(didLoad menu: Menuable) {
    if url != nil {
      menu.activate()
    }
  }

  func menu(didClick menu: Menuable) {
    guard let aUrl = url else {
      return menu.add(error: "Could not parse URL with value \(raw)")
    }

    App.open(url: aUrl)
  }

  func equals(_ param: Param) -> Bool {
    if let href = param as? Href {
      return href.raw == raw
    }

    return false
  }
}
