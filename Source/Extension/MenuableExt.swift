import AppKit

extension Menuable {
  var args: [String] {
    return params.reduce([Argument]()) { acc, param in
      switch param {
      case let .argument(arg):
        return acc + [arg]
      default:
        return acc
      }
    }.sorted { a, b in a.key < b.key }.map { arg in
      return arg.value
    }
  }

  var lines: [Paramable] {
    return params.reduce([]) { acc, param in
      switch param {
      case let .param(par):
        return acc + [par]
      default:
        return acc
      }
    }
  }

  init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /* TODO: Move this code to Parser.swift */
  /* TODO: Optimize, can be done in one iteration over params */
  internal var sortedParams: [Paramable] {
    var pParams = lines
    if (!lines.some { type(of: $0) == Trim.self }) {
      pParams.append(Trim(true))
    }

    let sorted = pParams.filter { param in
      (!param.after.isEmpty || !param.before.isEmpty)
      && !param.after.some { c in c == All.self }
      && !param.before.some { c in c == All.self }
    }
    .sorted { a, b in !a.after.some { c in type(of: b) == c } }
    .sorted { a, b in a.before.some { c in type(of: b) == c } }

    // Sort {nothing} to make the output consistent
    let nothing = pParams.filter { ($0.after + $0.before).isEmpty }.sorted { a, b in
      String(describing: type(of: a)).characters.count > String(describing: type(of: b)).characters.count /* Sort by anything */
    }
    let after = pParams.filter { $0.after.some { c in c == All.self } }
    let before = pParams.filter { $0.before.some { c in c == All.self } }
    return before + sorted + nothing + after
  }

  internal var menus: [Menu] {
    return items.reduce([Menu]()) { acc, menu in
      switch menu {
      case is Menu:
        return acc + [menu as! Menu]
      default:
        if menu.isSeparatorItem {
          return acc + [Menu(isSeparator: true)]
        }

        preconditionFailure("[Bug] Invalid class \(menu)")
      }
    }
  }

  func set(headline: Mutable) {
    self.headline = headline
  }

  func set(headline: String) {
    set(headline: headline.mutable())
  }

  func activate() {
    set(state: NSOnState)
  }

  func dectivate() {
    set(state: NSOffState)
  }

  func add(menus: [Menu]) {
    for menu in menus {
      menu.parentable = self
      if menu.isSeparator() {
        add(menu: NSMenuItem.separator())
      } else {
        add(menu: menu)
      }
    }
    load()
  }

  /**
    Display an @image instead of text
  */
  func set(image anImage: NSImage, isTemplate: Bool = false) {
    anImage.isTemplate = isTemplate
    image = anImage
  }

  /**
    Set the font size to @size
  */
  func set(size: Float) {
    set(headline: headline.update(fontSize: size))
  }

  /**
    Use @color for the enture title
  */
  func set(color: NSColor) {
    set(headline: headline.style(with: .foreground(color)))
  }

  /**
    Use @fontName, i.e Times-Roman
  */
  func set(fontName: String) {
    set(headline: headline.update(fontName: fontName))
  }

  func add(error: String) {
    set(headline: ":warning: \(error)".emojifyed())
  }

  private func load() {
    for param in sortedParams {
      param.menu(didLoad: self)
    }

    listener = onDidClick {
      self.wait(params: self.sortedParams)
    }
  }

  private func wait(params: [Paramable]) {
    if params.isEmpty { return }
    let param = params.get(at: 0)!
    param.menu(didClick: self)
    param.menu(didClick: self, done: { error in
      if (error != nil) { self.add(error: error!) }
      var p1 = params
      p1.removeFirst()
      self.wait(params: p1)
    })
  }
}
