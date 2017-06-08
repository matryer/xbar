import Cocoa
import Script
import Alamofire
import AlamofireImage
import Parser

class Menu: MenuItem, Scriptable {
  typealias Param = Parser.Menu.Param

  internal var paction: Action = .nop
  private var script: Script?
  private var imageRequest: DataRequest?

  convenience init(image: Parser.Image, submenus: [NSMenuItem], params: [Param], action: Action) {
    switch image {
    case .base64:
      if let nsimage = image.nsImage {
        self.init(
          image: nsimage,
          submenus: submenus,
          isAlternate: Menu.isAlt(params),
          isChecked: Menu.isChk(params),
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
          isChecked: Menu.isChk(params),
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
        immutable: text.colorize(as: .item),
        submenus: tails.map { $0.menuItem },
        isAlternate: Menu.isAlt(params),
        isChecked: Menu.isChk(params),
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
      preconditionFailure("[Bug] Tails as separators isn't supported")
    case let .error(messages):
      self.init(errors: messages.map { String(describing: $0) })
    }
  }

  // Called when user clicks the menu item
  override func onDidClick() {
    switch paction {
    case .nop: return
    case let .href(url, events):
      broadcast(.openUrlInBrowser(url))
      if events.has(.refresh) {
        broadcast(.refreshPlugin)
      }
    case let .script(script) where script.openInTerminal:
     broadcast(.openScriptInTerminal(script))
      if script.refreshAfterExec { broadcast(.refreshPlugin) }
    case let .script(script):
      self.script = Script(path: script.path, args: script.args, delegate: self, autostart: true)
    case .refresh:
      broadcast(.refreshPlugin)
    }
  }

  // Background script succeded, send refresh request
  func scriptDidReceive(success: Script.Success) {
    switch paction {
    case let .script(script) where script.refreshAfterExec:
      broadcast(.refreshPlugin)
    default:
      break
    }

    script = nil
  }

  // Background script failed, send refresh request
  func scriptDidReceive(failure: Script.Failure) {
    set(error: String(describing: failure))
  }

  // Download url as image and update self.image
  private func handle(url: URL, type: Parser.Image.Sort) {
    imageRequest = Alamofire.request(url).responseImage { [weak self] response in
      if let image = response.result.value {
        image.isTemplate = type.isTemplate
        self?.image = image
        self?.title = ""
        self?.attributedTitle = "".immutable
      } else if let error = response.result.error {
        self?.set(error: String(describing: error))
      } else {
        self?.set(error: "Could not download image from \(url)")
      }
    }
  }

  private static func isAlt(_ params: [Parser.Menu.Param]) -> Bool {
    return params.reduce(false) { acc, param in
      switch param {
      case .alternate:
        return true
      default:
        return acc
      }
    }
  }

  private static func isChk(_ params: [Parser.Menu.Param]) -> Bool {
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
