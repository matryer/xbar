import Cocoa

extension Notification.Name {
  static let terminate = Notification.Name("terminate")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let center = DistributedNotificationCenter.default()
    let manager = FileManager.default
    let id = "com.getbitbar.BitBar"
    let running = NSWorkspace.shared().runningApplications
    let path = Bundle.main.bundlePath as NSString

    for app in running {
      if app.bundleIdentifier == id {
        return terminate()
      }
    }

    center.addObserver(self, selector: #selector(terminate), name: .terminate, object: id)

    var components = path.pathComponents
    components.removeLast()
    components.removeLast()
    components.removeLast()
    components.append("MacOS")
    components.append("BitBar")
    let newPath = NSString.path(withComponents: components)
    var isDir: ObjCBool = false
    guard manager.fileExists(atPath: newPath, isDirectory:&isDir) else {
      return print("[Error] BitBar binary \(newPath) not found")
    }

    NSWorkspace.shared().launchApplication(newPath)
    print("[Log] Starting main app from path \(newPath)")
  }

  func terminate() {
    print("[Log] Terminating Startup application")
    NSApp.terminate(nil)
  }
}
