import AppKit
import Cocoa
import BonMot
import Hue
import OcticonsSwift
import Async
import SwiftyBeaver

class Tray: Parent {
  public let log = SwiftyBeaver.self
  public weak var root: Parent?
  private static let center = NSStatusBar.system()
  private static let length = NSVariableStatusItemLength
  private var item: MenuBar
  static internal var item: MenuBar {
    return Tray.center.statusItem(withLength: length)
  }

  init(title: String, isVisible displayed: Bool = false, id: String? = nil, parent: Parent? = nil) {
    if App.isInTestMode() {
      self.item = TestBar()
    } else {
      self.item = Tray.item
    }

    if let id = id {
      item.tag = id
    }

    set(title: title)
    root = parent
    if displayed { show() } else { hide() }
  }

  public var attributedTitle: NSAttributedString? {
    get { return item.attributedTitle }
    set { Async.main { self.item.attributedTitle = newValue } }
  }

  public var menu: NSMenu? {
    set { Async.main { self.item.menu = newValue } }
    get { return item.menu }
  }

  /**
   Hides item from menu bar
  */
  public func hide() {
    Async.main { self.item.hide() }
  }

  /**
    Display item in menu bar
  */
  public func show() {
    Async.main { self.item.show() }
  }

  public func on(_ event: MenuEvent) {
    switch event {
    case .didSetError:
      set(error: true)
    default:
      break
    }
  }

  public func set(error: Bool) {
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
    let fontSize = Int(FontType.bar.size)
    let size = CGSize(width: fontSize, height: fontSize)
    let icon = OcticonsID.bug

    image = NSImage(
      octiconsID: icon,
      iconColor: App.inactiveColor,
      size: size
    )

    alternateImage = NSImage(
      octiconsID: icon,
      backgroundColor: .white,
      iconColor: .white,
      iconScale: 1.0,
      size: size
    )
  }

  private func hideErrorIcons() {
    image = nil
    alternateImage = nil
  }

  private var image: NSImage? {
    set { Async.main { self.button?.image = newValue } }
    get { return button?.image }
  }

  private var alternateImage: NSImage? {
    set { Async.main { self.button?.alternateImage = newValue } }
    get { return button?.alternateImage }
  }

  private var button: NSButton? {
    if let button = item.button {
      return button
    }

    log.error("Could not find button on status item (hide)")
    return nil
  }

  private func style(_ immutable: Immutable) -> Immutable {
    return immutable.styled(with: .font(FontType.bar.font))
  }

  private func style(_ string: String) -> Immutable {
    return string.styled(with: .font(FontType.bar.font))
  }
}
