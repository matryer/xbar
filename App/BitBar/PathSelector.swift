import Cocoa
import AppKit
import EmitterKit

/**
  File selector used to ask the user about which plugin folder to use
*/
class PathSelector: NSOpenPanel, NSOpenSavePanelDelegate {
  /* Text on button */
  private static let title = "Use as Plugins Directory"
  private let event = Event<URL>()

  /**
    @url First folder being displayed in the file selector
  */
  convenience init(withURL url: URL? = nil) {
    self.init()

    if let aURL = url {
      directoryURL = aURL
    }
    prompt = PathSelector.title
    allowsMultipleSelection = false
    canChooseDirectories = true
    canCreateDirectories = true
    canChooseFiles = false
    delegate = self
  }

  func ask(block: @escaping Block<URL>) {
    event.once { url in block(url) }
    runModal()
  }

  // TODO: Ignore .dotfiles using
  // More info: https://developer.apple.com/reference/appkit/nsopensavepaneldelegate/1535200-panel
  // optional func panel(_ sender: Any,
  //        shouldEnable url: URL) -> Bool
  func panel(_ sender: Any, validate url: URL) throws {
    event.emit(url)
  }
}
