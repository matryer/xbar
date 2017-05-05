import AppKit
import Parser
import EmitterKit

final class Title: NSMenu, Eventable {
  internal weak var parentable: Eventable?
  internal var headline: Mutable?

  init(title: String = "", menus: [Menu] = []) {
    self.headline = title.mutable()
    super.init(title: title)
    handle(menus: menus)
  }

  init(_ text: Parser.Text, menus: [Menu]) {
    super.init(title: "")
    self.headline = text.colorize
    handle(menus: menus)
  }

  convenience init(head: Parser.Menu.Head) {
    switch head {
    case let .text(text, tails):
      self.init(text, menus: tails.map(Menu.init(tail:)))
    case let .error(messages):
      self.init(errors: messages)
    }
  }

  convenience init(errors: [String]) {
    self.init(title: ":warning:".emojified, menus: errors.map(Menu.init(title:)))
  }

  convenience init(error: String) {
    self.init(errors: [error])
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

  /* TODO: Update us with :warning: */
  func didSetError() {
    parentable?.didSetError()
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
