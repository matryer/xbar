import Foundation
import Alamofire
import Cocoa

class OpenPluginHandler: Parent {
  weak var root: Parent?
  private let fileManager = FileManager.default
  private let components: NSURLComponents

  init(_ components: NSURLComponents, parent: Parent) {
    self.components = components
    self.root = parent
    handle()
  }

  private func handle() {
    guard let params = components.queryItems else {
      return print("[Error] Could not read params from url ")
    }

    var queries = [String: String]()
    for param in params {
      queries[param.name] = param.value
    }

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

    guard let destUrl = NSURL(scheme: "file", host: nil, path: destPath) else {
      return print("[Error] Could not get plugin dest folder")
    }

    guard let destFile = destUrl.appendingPathComponent(pluginFileName) else {
      return print("[Error] Could not append \(pluginFileName) to \(destPath)")
    }

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
