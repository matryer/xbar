import Foundation
import Alamofire
import SwiftyBeaver
import Cocoa

class OpenPluginHandler: Parent, GUI {
  internal let queue = OpenPluginHandler.newQueue(label: "OpenPluginHandler")
  internal weak var root: Parent?
  private let fileManager = FileManager.default
  private let queries: [String: String]
  internal let log = SwiftyBeaver.self

  init(_ queries: [String: String], parent: Parent) {
    self.queries = queries
    self.root = parent
    handle()
  }

  private func handle() {
    guard let src = queries["src"] else {
      return log.error("Invalid plugin url, src=... not found")
    }

    guard let title = queries["title"] else {
      return log.error("Invalid plugin url, title=... not found")
    }

    guard let pluginUrl = URL(string: src) else {
      return log.error("Could not read plugin url \(src)")
    }

    guard let pluginFileName = pluginUrl.pathComponents.last else {
      return log.error("Could not get plugin file name from \(src)")
    }

    guard let destPath = App.pluginPath else {
      return log.error("Could not get plugin dest folder")
    }

    let urlComponents = NSURLComponents()
    urlComponents.scheme = "file"
    urlComponents.path = destPath

    guard let destUrl = urlComponents.url else {
      return log.error("Could not get plugin dest folder")
    }

    let destFile = destUrl.appendingPathComponent(pluginFileName)

    let alert = NSAlert()
    let trusted =
      pluginUrl.path.hasPrefix("/matryer/bitbar-plugins") &&
        pluginUrl.host == "github.com"

    alert.messageText = "Download and install the plugin \(title)"
    if trusted {
      alert.informativeText = "Only install plugins from trusted sources."
    } else {
      alert.messageText += " from \(src)"
      alert.informativeText = "CAUTION: This plugin is not from the official BitBar repository. We recommend that you only install plugins from trusted sources."
    }

    alert.addButton(withTitle: "Install")
    alert.addButton(withTitle: "Cancel")

    perform {
      if alert.runModal() != NSAlertFirstButtonReturn {
        return self.log.info("User aborted openPlugin")
      }

      self.rest(file: destFile, src: src)
    }
  }

  private func rest(file: URL, src: String) {
    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
      return (file, [.removePreviousFile])
    }

    Alamofire.download(src, to: destination).response { [weak self] response in
      guard let this = self else { return }
      if let error = response.error {
        return this.log.error("Could not download \(src) to \(file): \(error.localizedDescription))")
      }

      do {
        try this.fileManager.setAttributes([.posixPermissions: 0o777], ofItemAtPath: file.path)
      } catch let error {
        return this.log.error("\(file.absoluteString): \(error.localizedDescription)")
      }

      self?.broadcast(.refreshAll)
    }
  }
}
