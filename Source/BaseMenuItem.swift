import AppKit

class BaseMenuItem: NSMenuItem, MenuItem {
  weak var _root: Parent?
  var isChecked: Bool {
    get { return NSOnState == state }
    set { state = newValue ? NSOnState : NSOffState }
  }
  init(
    mutable: Mutable,
    submenus: [NSMenuItem] = [],
    isAlternate: Bool = false,
    isChecked: Bool = false,
    isClickable: Bool = true,
    shortcut: String = ""
  ) {
    super.init(title: "", action: #selector(__onDidClick) as Selector?, keyEquivalent: shortcut)
    target = self
    attributedTitle = mutable

    if !submenus.isEmpty {
      submenu = NSMenu()
      submenu?.autoenablesItems = false
      for sub in submenus {
        sub.root = self
        submenu?.addItem(sub)
      }
    }

    state = isChecked ? NSOnState : NSOffState
    isEnabled = state(isClickable: isClickable)

    if isAlternate {
      self.isAlternate = true
      keyEquivalentModifierMask = NSAlternateKeyMask
    }
  }

  convenience init(errors: [String], submenus: [NSMenuItem] = []) {
    self.init(error: "Found errors", submenus: errors.map { Menu(title: $0, submenus: []) })
  }

  convenience init(error: String, submenus: [NSMenuItem] = []) {
    self.init(title: ":warning: ".emojified + error, submenus: submenus)
  }

  convenience init(
    image: NSImage,
    submenus: [NSMenuItem] = [],
    isAlternate: Bool = false,
    isChecked: Bool = false,
    isClickable: Bool = true,
    shortcut: String = ""
  ) {
    self.init(
      mutable: "".mutable(),
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
   isClickable: Bool = true,
   shortcut: String = ""
 ) {
    self.init(
     mutable: title.mutable(),
     submenus: submenus,
     isAlternate: isAlternate,
     isChecked: isChecked,
     isClickable: isClickable,
     shortcut: shortcut
    )
  }

  func set(title: String) {
    attributedTitle = title.mutable()
  }

  private func state(isClickable: Bool) -> Bool {
    if isSeparator {
      return false
    }

    if isClickable {
      return true
    }

    if let sub = submenu {
      return sub.numberOfItems != 0
    }

    if keyEquivalent.isEmpty {
      return false
    }

    return true
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
}
