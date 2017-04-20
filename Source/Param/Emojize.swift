import Emojize

final class Emojize: Param<Bool> {
  var priority = 15

  override func menu(didLoad menu: Menuable) {
    if value {
      menu.set(headline: menu.headline.string.emojifyed())
    }
  }
}
