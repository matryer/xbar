import AppKit
import Cocoa
import BonMot

/**
  Represents an item in the menu bar
*/

class Tray: Parent {
  static private let barfont = NSFont.menuBarFont(ofSize: 0)
  static private let fontawesome = NSFont(name:"FontAwesome", size: barFont.pointSize + 4)!
  static private let warning = ":warning:".emojified.styled(
    with: StringStyle(.font(fontawesome), .baselineOffset(-1))
  )
  internal weak var root: Parent?
  private static let center = NSStatusBar.system()
  private static let length = NSVariableStatusItemLength
  private var item: MenuBar
  internal var menu: NSMenu? {
    set { item.menu = newValue }
    get { return item.menu }
  }

  static internal var item: MenuBar {
    return Tray.center.statusItem(withLength: Tray.length)
  }
  var attributedTitle: NSAttributedString? {
    get { return item.attributedTitle }
    set { item.attributedTitle = newValue }
  }

  func set(error: String) {
    /* TODO */
    attributedTitle = Tray.warning
    broadcast(.didSetError)
  }

  func set(error: Bool) {
    attributedTitle = Tray.warning
    broadcast(.didSetError)
  }

  func set(title: Immutable) {
    attributedTitle = title.styled(with: .font(Tray.barfont))
  }

  func set(title: String) {
    set(title: title.immutable)
  }

  /**
    @title A title to be displayed in the menu bar
    @isVisible Makes it possible to hide item on start up
  */
  init(title: String, isVisible displayed: Bool = false, parent: Parent? = nil) {
    if App.isInTestMode() {
      self.item = TestBar()
    } else {
      self.item = Tray.item
    }

    set(title: title)
    root = parent
    if displayed { show() } else { hide() }
  }

  /**
   Hides item from menu bar
  */
  func hide() {
    item.hide()
  }

  /**
    Display item in menu bar
  */
  func show() {
    item.show()
  }

  func on(_ event: MenuEvent) {
    switch event {
    case .didSetError:
      set(error: true)
    default:
      break
    }
  }
}
