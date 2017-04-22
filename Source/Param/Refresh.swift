final class Refresh: Param<Bool> {
  var refreshable: Bool { return value }

  override func menu(didLoad menu: Menuable) {
    if refreshable { menu.activate() }
  }

  override func menu(didClick menu: Menuable) {
    if refreshable { menu.refresh() }
  }
}
