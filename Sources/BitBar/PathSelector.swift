import Cocoa
import SwiftyBeaver
import AppKit
import Files

/**
  File selector used to ask the user about which plugin folder to use
*/
// TODO: Ignore .dotfiles using
// More info: https://developer.apple.com/reference/appkit/nsopensavepaneldelegate/1535200-panel
// optional func panel(_ sender: Any,
//        shouldEnable url: URL) -> Bool
class PathSelector: NSObject, NSOpenSavePanelDelegate {
  private let log = SwiftyBeaver.self
  private static let title = "Use as Plugins Directory"
  private let panel = NSOpenPanel()
  /**
    @url First folder being displayed in the file selector
  */
  convenience init(withURL url: URL? = nil) {
    self.init()
    if let aURL = url {
//      panel.directoryURL = aURL
    // } else {
    //   panel.directoryURL = URL(fileURLWithPath: Folder.home.path, isDirectory: true)
    }
    panel.prompt = PathSelector.title
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.canChooseFiles = false
    // panel.delegate = self
  }

  func ask(block: @escaping Block<URL>) {
    if panel.runModal() == NSFileHandlingPanelOKButton {
      if self.panel.urls.count == 1 {
        block(self.panel.urls[0])
      } else {
        self.log.error("Invalid number of urls \(self.panel.urls)")
      }
    } else {
      self.log.info("User pressed close in plugin folder dialog")
    }
  }
}
