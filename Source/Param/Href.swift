import Foundation

final class Href: Param<URL> {
  var priority = 0
  override var original: String {
    return value.absoluteString
  }

  // var original: String {
  //   return escape(output)
  // }

  override func menu(didLoad menu: Menuable) {
    menu.activate()
  }

  override func menu(didClick menu: Menuable) {
    App.open(url: value)
  }
}
