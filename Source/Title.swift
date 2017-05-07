import Parser

final class Title: NSMenu, Parent {
  weak var root: Parent?
  internal var headline: Mutable?

  init(title: String, menus: [NSMenuItem] = []) {
    self.headline = title.mutable()
    super.init(title: title)
    handle(menus: menus)
  }

  init(_ text: Parser.Text, menus: [NSMenuItem]) {
    super.init(title: "")
    self.headline = text.colorize
    handle(menus: menus)
  }

  convenience init(head: Parser.Menu.Head) {
    switch head {
    case let .text(text, tails):
     self.init(text, menus: tails.map { $0.menuItem })
    case let .error(messages):
      self.init(errors: messages)
    }
  }

  convenience init(errors: [String]) {
    self.init(title: ":warning:".emojified, menus: errors.map { Menu(title: $0, submenus: []) })
  }

  convenience init(error: String) {
    self.init(errors: [error])
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func on(_ event: MenuEvent) {
    print("event: \(event) in title")
  }

  private func handle(menus: [NSMenuItem]) {
    for menu in menus {
      menu.root = self
      // if var sub = menu as? BaseMenuItem {
      //   sub.root = self
      //   addItem(sub)
      // } else {
      //   addItem(menu)
      // }
      addItem(menu)
    }
  }
}
