import AppKit
import BonMot
import SwiftyBeaver
import OcticonsSwift

class MenuItem: NSMenuItem, Parent {
  private var isError = false
  var isManualClickable: Bool?
  internal let log = SwiftyBeaver.self
  weak var _root: Parent?
  internal var isChecked: Bool {
    get { return NSOnState == state }
    set { state = newValue ? NSOnState : NSOffState }
  }
  internal var isClickable: Bool {
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
    attributedTitle = style(immutable)

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
      keyEquivalentModifierMask = .option
    }
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
     immutable: title.immutable,
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
    attributedTitle = style(error)
    showErrorIcons()

    if cascade {
      broadcast(.didSetError)
    }
  }

  @nonobjc func set(title: Immutable) {
    attributedTitle = style(title)
  }

  @nonobjc func set(error: Bool) {
    if error { showErrorIcons() } else { hideErrorIcons() }
  }

  func onDidClick() {
    /* NOP */
  }

  @objc func __onDidClick() {
    log.verbose("Clicked dropdown menu")
    onDidClick()
  }

  override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    if isError { return false }
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

  private func showErrorIcons() {
    // Disable menu item
    isError = true
    submenu?.update()

    let fontSize = Int(FontType.item.size)
    let size = CGSize(width: fontSize, height: fontSize)
    let icon = OcticonsID.bug

    image = NSImage(
      octiconsID: icon,
      iconColor: .black,
      size: size
    )
  }

  private func hideErrorIcons() {
    isError = false
    submenu?.update()
    image = nil
  }

  private func style(_ immutable: Immutable) -> Immutable {
    return immutable.styled(with: .font(FontType.item.font))
  }

  private func style(_ string: String) -> Immutable {
    return string.styled(with: .font(FontType.item.font))
  }
}
