import AppKit
import Cocoa

/**
  Represents an item in the menu bar
*/

class Tray: Titlable {
  var warningLabel = barWarn
  var textFont = barFont
  internal weak var root: Parent?
  internal var originalTitle: NSAttributedString?
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
