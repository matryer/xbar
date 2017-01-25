import Cocoa
import AppKit

/**
  File selector used to ask the user about which plugin folder to use
*/
// TODO: Ignore .dotfiles using
// More info: https://developer.apple.com/reference/appkit/nsopensavepaneldelegate/1535200-panel
// optional func panel(_ sender: Any,
//        shouldEnable url: URL) -> Bool
class PathSelector: NSOpenPanel, NSOpenSavePanelDelegate {
  private static let title = "Use as Plugins Directory"

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

  func ask(block: Block<URL?>) {
    runModal()
    block(url)
  }
}
