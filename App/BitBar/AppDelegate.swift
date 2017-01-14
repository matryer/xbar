import Cocoa

private let currentPath = Bundle.main.resourcePath!
public let examplePlugin = currentPath + "/" + "sub.1m.sh"
public let jsonEmojize = currentPath + "/" + "emoji.json"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, TrayDelegate {
  // TODO: Replace /a/... with a proper path
  let manager = PluginManager(path: "/a/plugin-folder")
  let tray = Tray(title: "BitBar", isVisible: true)
  let center = NSWorkspace.shared().notificationCenter
  let name = Notification.Name.NSWorkspaceDidWake

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    tray.delegate = self
    manager.delegate = self
    center.addObserver(
      self,
      selector: #selector(AppDelegate.applicationDidWakeup),
      name: name,
      object: nil
    )
  }

  func managerDidChangePlugins(_ plugins: [Plugin]) {
    if plugins.isEmpty {
      self.tray.show()
    } else {
      self.tray.hide()
    }
  }

  func managerDidQuit() {
    log("managerDidQuit", "Manager invoked 'quit', exiting")
    NSApp.terminate(self)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    log("applicationWillTerminate", "Application is terminating, telling manager")
    manager.quit()
  }

  func applicationDidWakeup() {
    log("receiveWakeNote", "Application woke up from sleep, refresh manager")
    manager.refresh()
  }

  func preferenceDidRefreshAll() {
    log("preferenceDidRefreshAll", "User choose 'refresh' in preference menu")
    manager.refresh()
  }

  func preferenceDidQuit() {
    log("preferenceDidQuit", "User choose 'quit' in preference menu")
    manager.quit()
  }

  func preferenceDidChangePluginFolder() {
    log("preferenceDidChangePluginFolder", "TODO")
  }

  private func log(_ org: String, _ message: String) {
    print("[LOG]", org, message)
  }
}
