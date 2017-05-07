import Cocoa
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, Parent {
  weak var root: Parent?
  private var manager: PluginManager?
  private let fileManager = FileManager.default

  func applicationDidFinishLaunching(_: Notification) {
    loadPluginManager()

    App.onDidWake {
      self.loadPluginManager()
    }

    NSAppleEventManager.shared().setEventHandler(self,
      andSelector: #selector(AppDelegate.handleEvent(_:withReplyEvent:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
    LSSetDefaultHandlerForURLScheme("bitbar" as CFString, App.id)
  }

  func handleEvent(_ event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
    guard let desc = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) else {
      return print("[Error] Could not read descriptor from bitbar://")
    }

    guard let string = desc.stringValue else {
      return print("[Error] Could not read url string from bitbar://")
    }

    guard let components = NSURLComponents(string: string) else {
      return print("[Error] Could not get components from url \(string)")
    }

    guard components.host == "openPlugin" else {
      return print("[Log] \(string) is not an openPlugin event")
    }

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

    Alamofire.download(src, to: destination).response { response in
      if let error = response.error {
        return print("[Error] Could not download \(src) to \(destFile): \(error.localizedDescription))")
      }

      do {
        try self.fileManager.setAttributes([.posixPermissions: 0o777], ofItemAtPath: destFile.path)
      } catch let error {
        return print("[Error] \(destFile.absoluteString): \(error.localizedDescription)")
      }

      self.loadPluginManager()
    }
  }

  private func loadPluginManager() {
    if let path = App.pluginPath {
      return loadManager(fromPath: path)
    }

    App.askAboutPluginPath {
      self.loadPluginManager()
    }
  }

  private func loadManager(fromPath path: String) {
    manager = PluginManager(path: path)
    manager?.root = self
  }

  func on(_ event: MenuEvent) {
    switch event {
    case .refreshAll:
      self.loadPluginManager()
    case .quitApplication:
      NSApp.terminate(self)
    case .openPluginFolder:
      if let path = App.pluginPath {
        App.open(path: path)
      }
    case .openWebsite:
      App.open(url: App.website)
    case .changePluginPath:
      App.askAboutPluginPath {
        self.loadPluginManager()
      }
    case .checkForUpdates:
      print("[TODO] Check for updates")
    case let .startOnLogin(state):
      App.update(autostart: state)
    default:
      break
    }
  }
}
