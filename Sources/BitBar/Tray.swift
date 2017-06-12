import AppKit
import Cocoa
import BonMot
import Hue
import OcticonsSwift
import Async
import SwiftyBeaver

class Tray: Parent {
  internal let log = SwiftyBeaver.self
  internal weak var root: Parent?
  private static let center = NSStatusBar.system()
  private static let length = NSVariableStatusItemLength
  private var item: MenuBar
  internal var menu: NSMenu? {
    set { item.menu = newValue }
    get { return item.menu }
  }

  static internal var item: MenuBar {
    return Tray.center.statusItem(withLength: length)
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
    Async.main { self.item.hide() }
  }

  /**
    Display item in menu bar
  */
  func show() {
    Async.main { self.item.show() }
  }

  func on(_ event: MenuEvent) {
    switch event {
    case .didSetError:
      set(error: true)
    default:
      break
    }
  }

  func set(error: Bool) {
    if error {
      showErrorIcons()
      attributedTitle = nil
    } else { hideErrorIcons() }
  }

  func set(title: Immutable) {
    hideErrorIcons()
    attributedTitle = style(title)
  }

  func set(title: String) {
    set(title: title.immutable)
  }

  private func showErrorIcons() {
    guard let button = item.button else {
      return log.error("Could not find button on status item (show)")
    }

    let fontSize = Int(FontType.bar.size)
    let size = CGSize(width: fontSize, height: fontSize)
    let icon = OcticonsID.bug

    button.image = NSImage(
      octiconsID: icon,
      iconColor: App.inactiveColor,
      size: size
    )

    button.alternateImage = NSImage(
      octiconsID: icon,
      backgroundColor: .white,
      iconColor: .white,
      iconScale: 1.0,
      size: size
    )
  }

  private func hideErrorIcons() {
    guard let button = item.button else {
      return log.error("Could not find button on status item (hide)")
    }

    button.image = nil
    button.alternateImage = nil
  }

  private func style(_ immutable: Immutable) -> Immutable {
    return immutable.styled(with: .font(FontType.bar.font))
  }

  private func style(_ string: String) -> Immutable {
    return string.styled(with: .font(FontType.bar.font))
  }
}
