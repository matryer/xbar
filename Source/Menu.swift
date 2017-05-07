import Hue
import Cocoa
import AppKit
import Async
import EmitterKit
import Parser

class Menu: BaseMenuItem, ScriptDelegate {
  typealias Param = Parser.Menu.Param
  var paction: Action = .nop
  var script: Script?

  convenience init(image: Image, submenus: [NSMenuItem], params: [Param], action: Action) {
    switch image {
    case .base64:
      if let nsimage = image.nsImage {
        self.init(
          image: nsimage,
          submenus: submenus,
          isAlternate: Menu.isAlt(params),
          isChecked: Menu.isChecked(params),
          isClickable: action.isClickable
        )
      } else {
        self.init(error: "Could not get image from base64 input")
      }
    case let .href(url, type):
      if let anUrl = URL(string: url) {
        self.init(
          title: "Loading image…",
          submenus: submenus,
          isAlternate: Menu.isAlt(params),
          isChecked: Menu.isChecked(params),
          isClickable: action.isClickable
        )

        handle(url: anUrl, type: type)
      } else {
        self.init(error: "Could not parse url")
      }
    }

    self.paction = action
  }

  convenience init(tail: Parser.Menu.Tail) {
    switch tail {
    case let .text(text, params, tails, action):
      self.init(
        mutable: text.colorize,
        submenus: tails.map { $0.menuItem },
        isAlternate: Menu.isAlt(params),
        isChecked: Menu.isChecked(params),
        isClickable: action.isClickable
      )
      self.paction = action
    case let .image(image, params, tails, action):
      self.init(
        image: image,
        submenus: tails.map { $0.menuItem },
        params: params,
        action: action
      )
      self.paction = action
    case .separator:
      preconditionFailure("Tails as separators isn't supported")
    case let .error(messages, _):
      self.init(errors: messages)
    }
  }

  func on(_ event: MenuItem) {
    print("event: \(event) in menu: \(String(describing: root))")
  }

  override func onDidClick() {
    broadcast(.refreshPlugin)
    switch paction {
    case .nop: return
    case let .href(url, events):
      App.open(url: url)

      if events.has(.refresh) {
        broadcast(.refreshPlugin)
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
        broadcast(.refreshPlugin)
      }
    case .refresh:
      broadcast(.refreshPlugin)
    }
  }

  func scriptDidReceive(success: Script.Success) {
    if shouldRefresh { broadcast(.refreshPlugin) }
  }

  func scriptDidReceive(failure: Script.Failure) {
    set(error: String(describing: failure))
  }

  private func set(error: String) {
    attributedTitle = (":warning: ".emojified + error).mutable
    broadcast(.didSetError)
  }

  private func handle(url: URL, type: Parser.Image.Sort) {
    Async.background { () -> ImageResult in
      do {
        return try .data(Data(contentsOf: url))
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
        self.image = image
        self.title = ""
        self.attributedTitle = Mutable(string: "")
      case let .error(message):
        self.set(error: message)
      case .data:
        preconditionFailure("[Bug] Invalid state. Data now allowed here")
      }
    }
  }

  private var shouldRefresh: Bool {
    switch paction {
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

  static func isAlt(_ params: [Parser.Menu.Param]) -> Bool {
    return params.reduce(false) { acc, param in
      switch param {
      case .alternate:
        return true
      default:
        return acc
      }
    }
  }

  static func isChecked(_ params: [Parser.Menu.Param]) -> Bool {
    return params.reduce(false) { acc, param in
      switch param {
      case .checked:
        return true
      default:
        return acc
      }
    }
  }
}
