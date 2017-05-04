extension Raw {
  struct Acc {
    typealias Script = (String?, [Int: String])
    var text: Text = Text(title: "", params: [])
    var errors: [String] = []
    var terminal = false
    var refresh = false
    var params: [Menu.Param] = []
    var menus: [Menu.Tail] = []
    var script: (String?, [Int: String]) = (nil, [:])
    var image: Image?
    var href: String?
    var dropdown: Bool = true

    init(text: Text = Text(title: "", params: []), errors: [String] = [], terminal: Bool = false, refresh: Bool = false, params: [Menu.Param] = [], menus: [Menu.Tail] = [], script: (String?, [Int: String]) = (nil, [:]), image: Image? = nil, href: String? = nil, dropdown: Bool = true) {
      self.text = text
      self.errors = errors
      self.terminal = terminal
      self.refresh = refresh
      self.params = params
      self.menus = menus
      self.script = script
      self.image = image
      self.href = href
      self.dropdown = dropdown
    }

    init(title: String) {
      self.init(text: Text(title: title, params: []))
    }

    init(text: Text? = nil, errors: [String]? = nil, terminal: Bool? = nil, refresh: Bool? = nil, params: [Menu.Param]? = nil, menus: [Menu.Tail]? = nil, script: (String?, [Int: String])? = nil, image: Image? = nil, href: String? = nil, dropdown: Bool? = nil, using acc: Acc) {
      self.init(
        text: text ?? acc.text,
        errors: errors ?? acc.errors,
        terminal: terminal ?? acc.terminal,
        refresh: refresh ?? acc.refresh,
        params: params ?? acc.params,
        menus: menus ?? acc.menus,
        script: script ?? acc.script,
        image: image ?? acc.image,
        href: href ?? acc.href,
        dropdown: dropdown ?? acc.dropdown
      )
    }

    func add(param: Menu.Param) -> Acc {
      return Acc(params: params + [param], using: self)
    }

    func add(bash path: String) -> Acc {
      switch script {
      case let (_, args):
        return Acc(script: (path, args), using: self)
      }
    }

    func set(menus: [Menu.Tail]) -> Acc {
      return Acc(menus: menus, using: self)
    }

    func add(param: Text.Param) -> Acc {
      return Acc(text: text.add(param: param), using: self)
    }

    func set(href: String) -> Acc {
      return Acc(href: href, using: self)
    }

    func set(image: Image) -> Acc {
      return Acc(image: image, using: self)
    }

    func set(terminal state: Bool) -> Acc {
      return Acc(terminal: state, using: self)
    }

    func set(dropdown state: Bool) -> Acc {
      return Acc(dropdown: state, using: self)
    }

    func set(refresh state: Bool) -> Acc {
      return Acc(refresh: state, using: self)
    }

    func add(error: String) -> Acc {
      return Acc(errors: errors + [error], using: self)
    }

    func add(_ index: Int, value: String) -> Acc {
      switch script {
      case let (path, args):
        return Acc(script: (path, args + [index: value]), using: self)
      }
    }

    func reduce() -> Menu.Tail {
      return menu
    }

    var action: State<Menu.Action, String> {
      switch (href, script, refresh, terminal) {
      case (_, (.none, _), _, true):
        return .fail("Terminal can't exist without script")
      case let (.some(url), (.none, _), _, _):
        return .succ(.href(url, refresh, terminal))
      case let (.none, (.some(path), args), _, _):
        return .succ(.script(path, sort(args), refresh, terminal))
      case let (.none, (.none, args), _, _) where !args.isEmpty:
        return .fail("Script can't have args but no path")
      case (.none, (.none, _), true, _):
        return .succ(.refresh)
      case (.none, (.none, _), false, _):
        return .succ(.nop)
      case (.some, (.some, _), _, _):
        return .fail("Can't define both bash and href")
      }
    }

    private func sort(_ args: [Int: String]) -> [String] {
      return args.keys.sorted { a, b in a < b }.map { args[$0]! }
    }

    func error(_ message: String) -> Menu.Tail {
      return .error(errors + [message])
    }

    var menu: Menu.Tail {
      guard errors.isEmpty else {
        return .error(errors)
      }

      if text.isSeparator && !params.isEmpty {
        return error("Separator can't have params")
      }

      switch (image, action, text.isSeparator) {
      case (.some, _, true):
        return error("Can't define a separator with image")
      case (.none, .succ(.nop), true):
        return .separator
      case (.none, .succ, true):
        return error("Separator can't define actions, i.e refresh")
      case let (.some(image), .succ(action), _):
        return .image(image, params, [], action)
      case let (.none, .succ(action), false):
        return .text(text, params, [], action)
      case (.none, .succ(.nop), true):
        return .separator
      case let (_, .fail(message), _):
        return error(message)
      default:
        return error("Invalid state in Acc.menu(\(String(describing: image)), \(action), \(text.isSeparator))")
      }
    }
  }
}
