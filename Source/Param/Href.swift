import Foundation

final class Href: Param<URL> {
  var priority = 0
  override var original: String {
    return value.absoluteString
  }

  override func menu(didLoad menu: Menuable) {
    menu.activate()
  }

  override func menu(didClick menu: Menuable) {
    App.open(url: value)
  }
}
