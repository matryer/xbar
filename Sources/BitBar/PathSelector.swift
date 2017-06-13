import Cocoa
import SwiftyBeaver
import Async
import AppKit
import Files

class PathSelector {
  private let log = SwiftyBeaver.self
  // internal let queue = PathSelector.newQueue(label: "PathSelector")
  private static let title = "Use as Plugins Directory"
  private let panel = NSOpenPanel()
  /**
    @url First folder being displayed in the file selector
  */
  convenience init(withURL url: URL? = nil) {
    self.init()

    if let aURL = url {
      log.info("use other folder")
      panel.directoryURL = aURL
    } else {
      log.info("Use home folder")
      panel.directoryURL = URL(fileURLWithPath: Folder.home.path, isDirectory: true)
    }

    log.info("Use dir \(panel.directoryURL?.absoluteString)")

    panel.prompt = PathSelector.title
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.canChooseFiles = false
  }

  public func ask(block: @escaping Block<URL>) {
    Async.main {
      if self.panel.runModal() == NSFileHandlingPanelOKButton {
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
}
