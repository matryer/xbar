import Cocoa
import Emojize
import AppKit
import Async
// import Sparkle
import Vapor
import SwiftyBeaver

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, Parent {
  weak var root: Parent?
  internal let log = SwiftyBeaver.self
  private var eventManager = NSAppleEventManager.shared()
  private var notificationCenter = NSWorkspace.shared().notificationCenter
  internal let manager = PluginManager.instance
  // private let updater = SUUpdater.shared()
  private var trays = [Tray]()
  private var server: Droplet?
  var menus = [NSMenu]()
  var subs = [NSMenuItem]()

  func applicationDidFinishLaunching(_: Notification) {
    if App.isInTestMode() { return }
    manager.root = self
    setOpenUrlHandler()
    loadPluginManager()
    setOnWakeUpHandler()
    handleStartupApp()
    handleServerStartup()
  }

  private func handleStartupApp() {
    App.terminateHelperApp()
  }

  func on(_ event: MenuEvent) {
    switch event {
    case .refreshAll: manager.refresh()
    case .openWebsite: App.open(url: App.website)
    case .openOnLogin: App.startAtLogin(true)
    case .doNotOpenOnLogin: App.startAtLogin(false)
    case let .openUrlInBrowser(url): App.open(url: url)
    case .quitApplication: NSApp.terminate(self)
    case .checkForUpdates: break // updater?.checkForUpdates(self)
    case .openPluginFolder:
      if let path = App.pluginPath {
        App.open(path: path)
      }
    case .changePluginPath: askAboutPluginPath()
    case let .openPathInTerminal(path):
      open(script: path)
    case let .openScriptInTerminal(script):
      open(script: script.path, args: script.args)
    default:
      log.info("Ignored event in AppDelegate: \(event)")
    }
  }

  private func loadPluginManager() {
    if let path = App.pluginPath {
      return manager.set(path: path)
    }

    askAboutPluginPath()
  }

  private func askAboutPluginPath() {
    App.askAboutPluginPath {
      Async.main {
        self.loadPluginManager()
      }
    }
  }

  @objc private func onDidWake() {
    manager.refresh()
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
      return log.error("Could not read descriptor from bitbar://")
    }

    guard let string = desc.stringValue else {
      return log.error("Could not read url string from bitbar://")
    }

    guard let components = NSURLComponents(string: string) else {
      return log.error("Could not get components from url \(string)")
    }

    guard let params = components.queryItems else {
      return log.error("Could not read params from url ")
    }

    var queries = [String: String]()
    for param in params {
      queries[param.name] = param.value
    }

    switch components.host {
    case .some("openPlugin"):
      _ = OpenPluginHandler(queries, parent: self)
    case .some("refreshPlugin"):
      _ = RefreshPluginHandler(queries, manager: manager)
    case let other:
      log.error("\(String(describing: other)) is not a supported protocol")
    }
  }

  private func open(script path: String, args: [String] = []) {
    App.openScript(inTerminal: path, args: args) { maybe in
      if let error = maybe {
        self.log.error("open in app delegate: \(error)")
      }
    }
  }

  private func handleServerStartup() {
    do {
      server = try startServer()
    } catch {
      log.error("Could not start server: \(error)")
    }
  }
}
