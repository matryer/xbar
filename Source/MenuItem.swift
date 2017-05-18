import AppKit
import BonMot

class MenuItem: NSMenuItem, Parent {
  static private let menuFont = NSFont.menuFont(ofSize: 0)
  static private let fontawesome = NSFont(name:"FontAwesome", size: menuFont.pointSize + 1)!
  static private let warning = ":warning:".emojified.styled(
    with: StringStyle(.font(fontawesome), .baselineOffset(-1))
  )
  // var warningLabel = menuWarn
  // var textFont = menuFont
  var isManualClickable: Bool?
  weak var _root: Parent?
  // internal var originalTitle: NSAttributedString?
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
    attributedTitle = immutable
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
    self.init(
      error: "\(errors.count) errors",
      submenus: errors.map { Menu(title: $0, submenus: []) }
    )
  }

  convenience init(error: String, submenus: [NSMenuItem] = []) {
    /* TODO: Dont pass an empty string */
    self.init(title: "", submenus: submenus)
    set(error: error)
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
     immutable: title.styled(with: .font(MenuItem.menuFont)),
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

  func set(error: String) {
    set(error: error.immutable)
  }

  func set(title: String) {
    set(title: title.immutable)
  }

  @nonobjc func set(error: Immutable, cascade: Bool = true) {
    attributedTitle = Immutable.composed(of: [
      MenuItem.warning,
      Tab.headIndent(10),
      error.styled(with: .font(MenuItem.menuFont))
    ])

    if cascade {
      broadcast(.didSetError)
    }
  }

  @nonobjc func set(title: Immutable) {
    attributedTitle = title.styled(with: .font(MenuItem.menuFont))
  }

  @nonobjc func set(error: Bool) {
    if let title = attributedTitle {
      set(error: title, cascade: false)
    }
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
