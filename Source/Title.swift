import AppKit
import Parser
import EmitterKit

final class Title: NSMenu, Eventable {
  internal weak var parentable: Eventable?
  internal var headline: Mutable?

  init(_ title: String = "", menus: [Menu] = []) {
    self.headline = title.mutable()
    super.init(title: title)
    handle(menus: menus)
  }

  convenience init(head: Parser.Menu.Head) {
    switch head {
    case let .text(text, tails):
      self.init(text, menus: tails.map(Menu.init(tail:)))
    case let .error(messages):
      preconditionFailure("Error: \(messages)")
    }
  }

  init(_ text: Parser.Text, menus: [Menu]) {
    super.init(title: "")
    self.headline = text.colorize
    handle(menus: menus)
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func didTriggerRefresh() {
    refresh()
  }

  func refresh() {
    parentable?.didTriggerRefresh()
  }

  func didClickOpenInTerminal() {
    parentable?.didClickOpenInTerminal()
  }

  private func handle(menus: [Menu]) {
    for menu in menus {
      if menu.isSeparator() {
        addItem(NSMenuItem.separator())
      } else {
        menu.parentable = self
        addItem(menu)
      }
    }
  }
}
