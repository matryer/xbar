final class Length: Param<Int> {
  override var after: Filter { return [All.self] }

  override func menu(didLoad menu: Menuable) {
    guard value > 0 else {
      return menu.add(error: "Length is less or equal to zero")
    }

    menu.set(headline: menu.headline.truncate(value))
  }
}
