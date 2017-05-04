import Hue
import Cocoa
import AppKit
import EmitterKit
import Parser

final class Menu: ItemBase, Eventable {
  var paction: Parser.Action?
  var headline: Mutable {
    get { return attributedTitle?.mutable() ?? Mutable() }
    set { attributedTitle = newValue }
  }

  init(_ title: String, menus: [Menu] = []) {
    super.init(title)
    handle(menus: menus)
  }

  init(image data: Data, sort: Parser.Image.Sort, menus: [Menu]) {
    super.init("")
    switch sort {
    case .normal:
      self.image = NSImage(data: data, isTemplate: false)
    case .template:
      self.image = NSImage(data: data, isTemplate: true)
    }
    handle(menus: menus)
  }

  convenience init(image: Parser.Image, params: [Parser.Menu.Param], menus: [Menu], action: Action) {
    switch image {
    case let .base64(string, sort):
      guard let data = Data(base64Encoded: string) else {
        preconditionFailure("no image")
      }

      self.init(image: data, sort: sort, menus: menus)
    case .href:
      self.init("URL IMAGE....")
//      self.init(image: try! Data(contentsOf: URL(string: url)!), sort: sort, menus: menus)
    }

    handle(action: action)
    handle(params: params)
  }

  init(_ text: Parser.Text, params: [Parser.Menu.Param], menus: [Menu], action: Parser.Action) {
    super.init("")
    headline = text.colorize
    handle(action: action)
    handle(params: params)
    handle(menus: menus)
  }

  private func handle(params: [Parser.Menu.Param]) {
    for param in params {
      switch param {
      case .checked:
        self.state = NSOnState
      case .alternate:
        isAlternate = true
        keyEquivalentModifierMask = NSAlternateKeyMask
      }
    }
  }

  private func handle(menus: [Menu]) {
    for menu in menus {
      menu.parentable = self
      if menu.isSeparator() {
        add(menu: NSMenuItem.separator())
      } else {
        add(menu: menu)
      }
    }
  }

  private func handle(action: Parser.Action) {
    self.paction = action
    switch action {
    case .nop:
      return
    default:
      activate()
    }
  }

  convenience init(tail: Parser.Menu.Tail) {
    switch tail {
    case let .text(text, params, tails, action):
      self.init(text, params: params, menus: tails.map(Menu.init(tail:)), action: action)
    case let .image(image, params, tails, action):
      self.init(image: image, params: params, menus: tails.map(Menu.init(tail:)), action: action)
    case .separator:
      self.init(isSeparator: true)
    case let .error(messages):
      preconditionFailure("Error: \(messages)")
    }
  }

  @objc override func didClick(_ sender: NSMenu) {
    guard let action = paction else {
      return
    }

    switch action {
    case .nop: break
    case let .href(url, events):
      App.open(url: url)

      if events.has(.refresh) {
        self.refresh()
      }
    case let .script(.background(path, _, events)):
//      Bash.open(script: path, args: args) {
//        print("done (1): \($0)")
//      }

      print("TODO: Open in background (\(path))")

      if events.has(.refresh) {
        self.refresh()
      }
    case let .script(.foreground(path, _, events)):
      Bash.open(script: path) {
        print("done (2): \($0)")
      }

      if events.has(.refresh) {
        self.refresh()
      }
    case .refresh:
      self.refresh()
    }
  }

  /**
    @title A title to be displayed as an item in a menu bar
    @params Parameters read and parsed from stdin, i.e terminal=false
    @menus Sub menus for this item
    @level The number of levels down from the tray
  */
  convenience init(isSeparator: Bool) {
    self.init("-")
    isHidden = true
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func refresh() {
    didTriggerRefresh()
  }

  /**
    Menus starting with a dash "-" are considered separators
  */
  func isSeparator() -> Bool {
    return title.trim() == "-"
  }

  func didTriggerRefresh() {
    parentable?.didTriggerRefresh()
  }

  func didClickOpenInTerminal() {
    parentable?.didClickOpenInTerminal()
  }
}
