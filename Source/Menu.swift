import Hue
import Cocoa
import AppKit
import Async
import EmitterKit
import Parser

enum ImageResult {
  case data(Data)
  case image(NSImage)
  case error(String)
}

extension Parser.Image.Sort {
  var isTemplate: Bool {
    switch self {
    case .template:
      return true
    default:
      return false
    }
  }
}

final class Menu: ItemBase, Eventable, ScriptDelegate {
  var script: Script?
  var paction: Parser.Action?
  var headline: Mutable {
    get { return attributedTitle?.mutable() ?? Mutable() }
    set { attributedTitle = newValue }
  }

  init(title: String) {
    super.init(title)
  }

  convenience init(title: String, menus: [Menu]) {
    self.init(title: title)
    handle(menus: menus)
  }

  convenience init(errors: [String]) {
    self.init(title: ":warning: ".emojified, menus: errors.map(Menu.init(title:)))
  }

  convenience init(image data: Data, sort: Parser.Image.Sort, menus: [Menu]) {
    self.init(title: "", menus: menus)
    switch sort {
    case .normal:
      self.image = NSImage(data: data, isTemplate: false)
    case .template:
      self.image = NSImage(data: data, isTemplate: true)
    }
  }

  convenience init(image: Parser.Image, params: [Parser.Menu.Param], menus: [Menu], action: Action) {
    switch image {
    case let .base64(string, sort):
      if let data = Data(base64Encoded: string) {
        self.init(image: data, sort: sort, menus: menus)
      } else {
        self.init(error: "Could not read base64 image")
      }
    case let .href(url, type):
      self.init(title: "Loading image...")
      handle(url: url, type: type)
    }
    handle(action: action)
    handle(params: params)
  }

  convenience init(_ text: Parser.Text, params: [Parser.Menu.Param], menus: [Menu], action: Parser.Action) {
    self.init(title: "", menus: menus)
    headline = text.colorize
    handle(action: action)
    handle(params: params)
  }

  convenience init(error: String) {
    self.init(errors: [error])
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

  private func set(error: String) {
    self.headline = (":warning:".emojified + " " + error).mutable
    parentable?.didSetError()
  }

  private func set(image: NSImage) {
    self.title = ""
    self.headline = "".mutable
    self.image = image
  }

  private func handle(menus: [Menu]) {
    for menu in menus {
      menu.parentable = self
      if menu.isSeparator {
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
    case let .error(messages, _):
      self.init(errors: messages)
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
        refresh()
      }
    case let .script(.background(path, args, _)):
      script = Script(path: path, args: args, delegate: self, autostart: true)
    case let .script(.foreground(path, events)):
      App.openScript(inTerminal: path) { error in
        if let anError = error {
          self.set(error: anError)
        }
      }

      if events.has(.refresh) {
        refresh()
      }
    case .refresh:
      refresh()
    }
  }

  func scriptDidReceive(success: Script.Success) {
    print("[Ok] Script succeeded with status \(success.status)")
    if shouldRefresh { refresh() }
  }

  func scriptDidReceive(failure: Script.Failure) {
    print("[Err] Script failed with \(failure) using action \(paction!)")
    set(error: String(describing: failure))
  }

  private func handle(url: String, type: Parser.Image.Sort) {
    guard let anUrl = URL(string: url) else {
      return set(error: "Could not parse url")
    }
    Async.background { () -> ImageResult in
      do {
        return try .data(Data(contentsOf: anUrl))
      } catch(let error) {
        return .error(error.localizedDescription)
      }
    }.background { result -> ImageResult in
      switch result {
      case let .data(data):
        if let anImage = NSImage(data: data, isTemplate: type.isTemplate) {
          return .image(anImage)
        }
        return .error("Could not download image from url")
      default:
        return result
      }
    }.main { result -> Void in
      switch result {
      case let .image(image):
        self.set(image: image)
      case let .error(message):
        self.set(error: message)
      case .data:
        preconditionFailure("[Bug] Invalid state. Data now allowed here")
      }
    }
  }

  private var shouldRefresh: Bool {
    switch paction! {
    case let .script(.background(_, _, events)) where events.has(.refresh):
      return true
    case let .script(.foreground(_, events)) where events.has(.refresh):
      return true
    case let .href(_, events) where events.has(.refresh):
      return true
    case .refresh:
      return true
    default:
      return false
    }
  }

  /**
    @title A title to be displayed as an item in a menu bar
    @params Parameters read and parsed from stdin, i.e terminal=false
    @menus Sub menus for this item
    @level The number of levels down from the tray
  */
  convenience init(isSeparator: Bool) {
    self.init(title: "-")
    isHidden = true
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // convenience init(error: String) {
  //   self.init(":warning: \(error)".emojified)
  // }
  //
  // required init(coder decoder: NSCoder) {
  //   fatalError("init(coder:) has not been implemented")
  // }

  func refresh() {
    didTriggerRefresh()
  }

  /**
    Menus starting with a dash "-" are considered separators
  */
  var isSeparator: Bool {
    return title.trimmed() == "-"
  }

  func didTriggerRefresh() {
    parentable?.didTriggerRefresh()
  }

  func didClickOpenInTerminal() {
    parentable?.didClickOpenInTerminal()
  }

  func didSetError() {
    parentable?.didSetError()
  }
}
