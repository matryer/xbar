import AppKit
import BonMot
import Async
import SwiftyBeaver
import OcticonsSwift

class MenuItem: NSMenuItem, Parent, GUI {
  internal let queue = MenuItem.newQueue(label: "MenuItem")
  private var isError = false
  public var isManualClickable: Bool?
  public let log = SwiftyBeaver.self
  public weak var _root: Parent?

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
    }

    for sub in submenus {
      add(submenu: sub)
    }

    self.isChecked = isChecked
    self.isManualClickable = isClickable

    if isAlternate {
      perform {
        self.isAlternate = true
        self.keyEquivalentModifierMask = .option
      }
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

    self.icon = image
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

  public var isClickable: Bool {
    return validateMenuItem(self)
  }

  public func set(error: String) {
    set(error: error.immutable)
  }

  public func set(title: String) {
    set(title: title.immutable)
  }

  @nonobjc public func set(error: Immutable, cascade: Bool = true) {
    set(title: error)
    showErrorIcons()

    if cascade {
      broadcast(.didSetError)
    }
  }

  @nonobjc public func set(title: Immutable) {
    perform { self.attributedTitle = self.style(title) }
  }

  @nonobjc public func set(error: Bool) {
    if error { showErrorIcons() } else { hideErrorIcons() }
  }

  public func onDidClick() {
    /* NOP */
  }

  public var isChecked: Bool {
    get { return NSOnState == state }
    set {
      perform {
        self.state = newValue ? NSOnState : NSOffState
      }
    }
  }

  @objc public func __onDidClick() {
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

  public func on(_ event: MenuEvent) {
    switch event {
    /* set(error: ...) was used */
    case .didSetError:
      set(error: true)
    default:
      break
    }
  }

  private func showErrorIcons() {
    isError = true

    let fontSize = Int(FontType.item.size)
    let size = CGSize(width: fontSize, height: fontSize)

    icon = NSImage(
      octiconsID: OcticonsID.bug,
      iconColor: .black,
      size: size
    )

    updateSubmenu()
  }

  private func hideErrorIcons() {
    isError = false
    icon = nil
    updateSubmenu()
  }

  private var icon: NSImage? {
    set { perform { self.image = newValue } }
    get { return image }
  }

  private func style(_ immutable: Immutable) -> Immutable {
    return immutable.styled(with: .font(FontType.item.font))
  }

  private func style(_ string: String) -> Immutable {
    return string.styled(with: .font(FontType.item.font))
  }

  private func add(submenu item: NSMenuItem) {
    perform {
      item.root = self
      self.submenu?.addItem(item)
    }
  }

  private func updateSubmenu() {
    perform { self.submenu?.update() }
  }
}
