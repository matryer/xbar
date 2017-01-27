import Cocoa
import AppKit

/**
  File selector used to ask the user about which plugin folder to use
*/
// TODO: Ignore .dotfiles using
// More info: https://developer.apple.com/reference/appkit/nsopensavepaneldelegate/1535200-panel
// optional func panel(_ sender: Any,
//        shouldEnable url: URL) -> Bool
class PathSelector: NSObject, NSOpenSavePanelDelegate {

  private static let title = "Use as Plugins Directory"
  private let panel = NSOpenPanel()
  /**
    @url First folder being displayed in the file selector
  */
  convenience init(withURL url: URL? = nil) {
    self.init()
    if let aURL = url {
      panel.directoryURL = aURL
    }
    panel.prompt = PathSelector.title
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.canChooseFiles = false
    panel.delegate = self
  }

  func ask(block: Block<URL?>) {
    panel.runModal()
    block(panel.url)
  }
}
