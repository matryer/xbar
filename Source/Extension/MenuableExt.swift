import AppKit

extension Menuable {
  func setting(terminal: Bool) {
    settings["terminal"] = terminal
  }

  func setting(refresh: Bool) {
    settings["refresh"] = refresh
  }

  func setting(dropdown: Bool) {
    settings["dropdown"] = dropdown
  }

  func setting(trim: Bool) {
    settings["trim"] = trim
  }

  func shouldTrim() -> Bool {
    return settings["trim"] ?? true
  }

  func add(arg: String) {
    args.append(arg)
  }

  func load() {
    let those = params.sorted { a, b in
      return a.priority > b.priority
    }

    for param in those {
      param.menu(didLoad: self)
    }

   listener = onDidClick {
     for param in those {
       param.menu(didClick: self)
     }
   }
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

  func add(menus: [Menu]) {
    guard hasDropdown else { return }
    for menu in menus {
      menu.parentable = self
      if menu.isSeparator() {
        add(menu: NSMenuItem.separator())
      } else {
        add(menu: menu)
      }
    }
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
}
