import Foundation
import Alamofire
import Cocoa

class OpenPluginHandler: Parent {
  weak var root: Parent?
  private let fileManager = FileManager.default
  private let queries: [String: String]

  init(_ queries: [String: String], parent: Parent) {
    self.queries = queries
    self.root = parent
    handle()
  }

  private func handle() {
    guard let src = queries["src"] else {
      return print("[Error] Invalid plugin url, src=... not found")
    }

    guard let title = queries["title"] else {
      return print("[Error] Invalid plugin url, title=... not found")
    }

    guard let pluginUrl = URL(string: src) else {
      return print("[Error] Could not read plugin url \(src)")
    }

    guard let pluginFileName = pluginUrl.pathComponents.last else {
      return print("[Error] Could not get plugin file name from \(src)")
    }

    guard let destPath = App.pluginPath else {
      return print("[Error] Could not get plugin dest folder")
    }

    let urlComponents = NSURLComponents()
    urlComponents.scheme = "file"
    urlComponents.path = destPath

    guard let destUrl = urlComponents.url else {
      return print("[Error] Could not get plugin dest folder")
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
    if alert.runModal() != NSAlertFirstButtonReturn {
      return print("[Log] User aborted openPlugin")
    }

    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
      return (destFile, [.removePreviousFile])
    }

    Alamofire.download(src, to: destination).response { [weak self] response in
      if let error = response.error {
        return print("[Error] Could not download \(src) to \(destFile): \(error.localizedDescription))")
      }

      do {
        try self?.fileManager.setAttributes([.posixPermissions: 0o777], ofItemAtPath: destFile.path)
      } catch let error {
        return print("[Error] \(destFile.absoluteString): \(error.localizedDescription)")
      }

      self?.broadcast(.refreshAll)
    }
  }

}
