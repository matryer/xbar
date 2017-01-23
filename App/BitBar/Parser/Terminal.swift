final class Terminal: BoolVal, Param {
  var priority: Int { return 0 }
  func applyTo(menu: Menuable) {
    /* NOP */
  }
}
