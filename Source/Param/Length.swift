final class Length: Param<Int> {
  var priority = 0

  override func menu(didLoad menu: Menuable) {
    // TODO: Check if {value} is > 0
    menu.set(headline: menu.headline.truncate(value))
  }
}
