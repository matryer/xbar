import Cocoa
import Sparkle
import ServiceManagement
import SwiftyUserDefaults

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, Parent {
  weak var root: Parent?
  private var eventManager = NSAppleEventManager.shared()
  private var notificationCenter = NSWorkspace.shared().notificationCenter
  private var manager: PluginManager?
  private let helperId = "com.getbitbar.Startup"
  private let updater = SUUpdater.shared()

  func applicationDidFinishLaunching(_: Notification) {
    if App.isInTestMode() { return }
    setOpenUrlHandler()
    loadPluginManager()
    setOnWakeUpHandler()
    handleStartupApp()
  }

  private func sendTerminateToHelper() {
    print("[Log] Sending terminate signal to helper app")
    DistributedNotificationCenter.default().post(name: .terminate, object: helperId)
  }

  private func handleStartupApp() {
    for app in NSWorkspace.shared().runningApplications {
      guard let id = app.bundleIdentifier else { continue }
      if id == helperId {
        return sendTerminateToHelper()
      }
    }
  }

  func on(_ event: MenuEvent) {
    switch event {
    case .refreshAll: loadPluginManager()
    case .openWebsite: App.open(url: App.website)
    case .openOnLogin: login(true)
    case .doNotOpenOnLogin: login(false)
    case let .openUrlInBrowser(url): App.open(url: url)
    case .quitApplication: NSApp.terminate(self)
    case .checkForUpdates: updater?.checkForUpdates(self)
    case .openPluginFolder:
      if let path = App.pluginPath {
        App.open(path: path)
      }
    case .changePluginPath:
      App.askAboutPluginPath { [weak self] in
        self?.loadPluginManager()
      }
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
    if let path = App.pluginPath {
      return loadManager(fromPath: path)
    }

    App.askAboutPluginPath { [weak self] in
      self?.loadPluginManager()
    }
  }

  private func loadManager(fromPath path: String) {
    if manager != nil { print("[Log] Reload plugin manager") }
    manager = PluginManager(path: path)
    manager?.root = self
  }

  private func login(_ state: Bool) {
    Defaults[.startAtLogin] = state
    SMLoginItemSetEnabled(helperId as CFString, state)
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

    guard let params = components.queryItems else {
      return print("[Error] Could not read params from url ")
    }

    var queries = [String: String]()
    for param in params {
      queries[param.name] = param.value
    }

    switch components.host {
    case .some("openPlugin"):
      _ = OpenPluginHandler(queries, parent: self)
    case .some("refreshPlugin"):
      if let pluginManager = manager {
        _ = RefreshPluginHandler(queries, manager: pluginManager)
      } else {
        print("[Error] Could not find any plugin manager")
      }
    case let other:
      print("[Error] \(String(describing: other)) is not a supported protocol")
    }
  }
}
