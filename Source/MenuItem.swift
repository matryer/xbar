import AppKit
import BonMot
func + (lhs: Immutable, rhs: Immutable) -> Immutable {
  return NSAttributedString.composed(of: [lhs, rhs])
}

class MenuItem: NSMenuItem, Titlable {
  var warningLabel = menuWarn
  var textFont = menuFont
  weak var _root: Parent?
  internal var originalTitle: NSAttributedString?
  var isChecked: Bool {
    get { return NSOnState == state }
    set { state = newValue ? NSOnState : NSOffState }
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
      submenu = NSMenu()
      submenu?.autoenablesItems = false
      for sub in submenus {
        sub.root = self
        submenu?.addItem(sub)
      }
    }

    self.isChecked = isChecked
    self.isEnabled = state(isClickable: isClickable)

    if isAlternate {
      self.isAlternate = true
      keyEquivalentModifierMask = NSAlternateKeyMask
    }
  }

  convenience init(errors: [String], submenus: [NSMenuItem] = []) {
    self.init(error: "Found errors", submenus: errors.map { Menu(title: $0, submenus: []) })
  }

  convenience init(error: String, submenus: [NSMenuItem] = []) {
    self.init(immutable: NSAttributedString.composed(of: [
      menuWarn,
      Special.noBreakSpace,
      error.immutable
    ]), submenus: submenus)
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

  private func state(isClickable: Bool?) -> Bool {
    if let sub = submenu {
      return sub.numberOfItems != 0
    }

    if isSeparator {
      return false
    }

    if !keyEquivalent.isEmpty {
      return true
    }

    if let state = isClickable {
      return state
    } else {
      return true
    }
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
