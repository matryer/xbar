import AppKit
import BonMot

class MenuItem: NSMenuItem, Titlable {
  var warningLabel = menuWarn
  var textFont = menuFont
  var isManualClickable: Bool?
  weak var _root: Parent?
  internal var originalTitle: NSAttributedString?
  var isChecked: Bool {
    get { return NSOnState == state }
    set { state = newValue ? NSOnState : NSOffState }
  }
  var isClickable: Bool {
    return validateMenuItem(self)
  }

  convenience init() {
    self.init(title: "…")
  }

  init(
    immutable: Immutable,
    submenus: [NSMenuItem] = [],
    isAlternate: Bool = false,
    isChecked: Bool = false,
    isClickable: Bool? = nil,
    shortcut: String = ""
  ) {
    super.init(
      title: "",
      action: #selector(__onDidClick) as Selector?,
      keyEquivalent: shortcut
    )

    target = self
    set(title: immutable)
    if !submenus.isEmpty {
      submenu = MenuBase()
      for sub in submenus {
        sub.root = self
        submenu?.addItem(sub)
      }
    }

    self.isChecked = isChecked
    self.isManualClickable = isClickable

    if isAlternate {
      self.isAlternate = true
      keyEquivalentModifierMask = NSAlternateKeyMask
    }
  }

  override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    if let state = isManualClickable {
      return state
    }

    if hasSubmenu {
      return true
    }

    if isSeparator {
      return false
    }

    return !keyEquivalent.isEmpty
  }

  convenience init(errors: [String], submenus: [NSMenuItem] = []) {
    self.init(error: "Found errors", submenus: errors.map { Menu(title: $0, submenus: []) })
  }

  convenience init(error: String, submenus: [NSMenuItem] = []) {
    self.init(immutable: NSAttributedString.composed(of: [
      menuWarn,
      Tab.headIndent(10),
      error.immutable
    ]), submenus: submenus, isClickable: true)
  }

  convenience init(
    image: NSImage,
    submenus: [NSMenuItem] = [],
    isAlternate: Bool = false,
    isChecked: Bool = false,
    isClickable: Bool? = nil,
    shortcut: String = ""
  ) {
    self.init(
      immutable: "".immutable,
      submenus: submenus,
      isAlternate: isAlternate,
      isChecked: isChecked,
      isClickable: isClickable,
      shortcut: shortcut
    )

    self.image = image
  }

 convenience init(
   title: String,
   submenus: [NSMenuItem] = [],
   isAlternate: Bool = false,
   isChecked: Bool = false,
   isClickable: Bool? = nil,
   shortcut: String = ""
 ) {
    self.init(
     immutable: title.styled(with: .font(menuFont)),
     submenus: submenus,
     isAlternate: isAlternate,
     isChecked: isChecked,
     isClickable: isClickable,
     shortcut: shortcut
    )
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func onDidClick() {
    /* NOP */
  }

  @objc func __onDidClick() {
    onDidClick()
  }

  override public var debugDescription: String {
    return String(describing: [
      "title": title,
      "isChecked": isChecked,
      "isAlternate": isAlternate,
      "isEnabled": isEnabled,
      "hasSubmenu": hasSubmenu,
      "keyEquivalent": keyEquivalent
    ])
  }

  // Event from children
  func on(_ event: MenuEvent) {
    switch event {
    /* set(error: ...) was used */
    case .didSetError:
      set(error: true)
    default:
      break
    }
  }
}
