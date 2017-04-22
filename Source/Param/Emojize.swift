import Emojize

final class Emojize: Param<Bool> {
  override var before: Filter { return [All.self] }

  override func menu(didLoad menu: Menuable) {
    if value {
      menu.set(headline: menu.headline.string.emojifyed())
    }
  }
}
