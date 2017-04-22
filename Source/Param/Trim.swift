final class Trim: Param<Bool> {
  // static var default: Trim { return Trim(true) }
  // override var before: Filter { return Everyone }
  var isTrimmable: Bool { return value }

  override func menu(didLoad menu: Menuable) {
    if isTrimmable {
      menu.set(headline: menu.headline.trimmed())
    }
  }
}
