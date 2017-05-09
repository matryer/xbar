import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, Parent {
  weak var root: Parent?
  private var eventManager = NSAppleEventManager.shared()
  private var notificationCenter = NSWorkspace.shared().notificationCenter
  private var manager: PluginManager?
  private var handler: OpenPluginHandler?

  func applicationDidFinishLaunching(_: Notification) {
    setOpenUrlHandler()
    loadPluginManager()
    setOnWakeUpHandler()
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
      App.askAboutPluginPath { [weak self] in
        self?.loadPluginManager()
      }
    case .checkForUpdates:
      SUUpdater.shared().checkForUpdates(self)
    case .openOnLogin:
      App.update(autostart: true)
    case .doNotOpenOnLogin:
      App.update(autostart: false)
    case let .openUrlInBrowser(url):
      App.open(url: url)
    case let .openScriptInTerminal(path):
      App.openScript(inTerminal: path) { maybe in
        if let error = maybe {
          print("[Error] openScriptInTerminal: \(error)")
        }
      }
    default:
      print("[Log] Ignored event in AppDelegate: \(event)")
    }
  }

  private func loadPluginManager() {
    print("[Log] Reload plugin manager")
    if let path = App.pluginPath {
      return loadManager(fromPath: path)
    }

    App.askAboutPluginPath { [weak self] in
      self?.loadPluginManager()
    }
  }

  private func loadManager(fromPath path: String) {
    manager = PluginManager(path: path)
    manager?.root = self
  }

  @objc private func onDidWake() {
    loadPluginManager()
  }

  private func setOnWakeUpHandler() {
    notificationCenter.addObserver(
      self,
      selector: #selector(onDidWake),
      name: .NSWorkspaceDidWake,
      object: nil
    )
  }

  private func setOpenUrlHandler() {
    eventManager.setEventHandler(self,
      andSelector: #selector(AppDelegate.handleEvent(_:withReplyEvent:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
    LSSetDefaultHandlerForURLScheme("bitbar" as CFString, App.id)
  }

  @objc private func handleEvent(_ event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
    guard let desc = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) else {
      return print("[Error] Could not read descriptor from bitbar://")
    }

    guard let string = desc.stringValue else {
      return print("[Error] Could not read url string from bitbar://")
    }

    guard let components = NSURLComponents(string: string) else {
      return print("[Error] Could not get components from url \(string)")
    }

    if components.host == "openPlugin" {
      handler = OpenPluginHandler(components, parent: self)
    }
  }
}
