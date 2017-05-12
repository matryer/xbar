import Parser
import BonMot

final class Title: NSMenu, Parent {
  weak var root: Parent?
  internal var headline: Immutable?
  
  init(immutable title: Immutable, menus: [NSMenuItem] = []) {
    super.init(title: "")
    self.headline = title
    for menu in menus {
      menu.root = self
      addItem(menu)
    }
  }

  convenience init(_ text: Parser.Text, menus: [NSMenuItem]) {
    self.init(immutable: text.colorize(as: .bar), menus: menus)
  }
  
  convenience init(title: String, menus: [NSMenuItem] = []) {
    self.init(immutable: title.immutable, menus: menus)
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
    self.init(immutable: barWarn, menus: errors.map { Menu(title: $0, submenus: []) })
  }

  convenience init(error: String) {
    self.init(errors: [error])
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
