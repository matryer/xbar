import Cocoa
// import FontAwesomeForMacOS
import Emojize
// import BonMot
import AppKit
import Sparkle
import BonMot

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, Parent {
  weak var root: Parent?
  private var eventManager = NSAppleEventManager.shared()
  private var notificationCenter = NSWorkspace.shared().notificationCenter
  private var manager: PluginManager?
  private let updater = SUUpdater.shared()
  private var trays = [Tray]()
  var menus = [NSMenu]()
  var subs = [NSMenuItem]()

  func applicationDidFinishLaunching(_: Notification) {
    if App.isInTestMode() { return }
    setOpenUrlHandler()
    loadPluginManager()
    setOnWakeUpHandler()
    handleStartupApp()
  }

  private func handleStartupApp() {
    App.terminateHelperApp()
  }

  func on(_ event: MenuEvent) {
    switch event {
    case .refreshAll: loadPluginManager()
    case .openWebsite: App.open(url: App.website)
    case .openOnLogin: App.startAtLogin(true)
    case .doNotOpenOnLogin: App.startAtLogin(false)
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
    case let .openPathInTerminal(path):
      open(script: path)
    case let .openScriptInTerminal(script):
      open(script: script.path, args: script.args)
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

  private func open(script path: String, args: [String] = []) {
    App.openScript(inTerminal: path, args: args) { maybe in
      if let error = maybe {
        print("[Error] open in app delegate: \(error)")
      }
    }
  }

//   func doStuff() {
//     // let image = NSImage.fontAwesomeIconWithName(.Github, textColor: .black, size: CGSize(width: 20, height: 20))
// //
// //    label.font = NSFont.fontAwesomeOfSize(50)
// //
//
//     let barFont = NSFont.menuBarFont(ofSize: 0)
//     let bigBarFont = NSFont.menuBarFont(ofSize: 21)
//     let itemFont = NSFont.menuFont(ofSize: 0)
//     let warning = ":warning:".emojified.styled(with: .font(barFont))
//     let bigWarn = ":warning:".emojified.styled(with: .font(bigBarFont), .baselineOffset(-2))
//     let bigWarnNoOff = ":warning:".emojified.styled(with: .font(bigBarFont))
//     let car = ":car:".emojified.styled(with: .font(barFont))
//     let text = "hello!".styled(with: .font(barFont))
//     let bigText = "hello!".styled(with: .font(barFont))
//     let bigTitle = bigWarnNoOff + bigText
//
//     let manager = FileManager.default
//
//     let tray1 = Tray(title: "MyTitle", isVisible: true)
//     let tray2 = Tray(title: "MyTitle", isVisible: true)
//     let tray3 = Tray(title: "MyTitle", isVisible: true)
//     let tray4 = Tray(title: "MyTitle", isVisible: true)
//     let tray5 = Tray(title: "MyTitle", isVisible: true)
//     let tray6 = Tray(title: "MyTitle", isVisible: true)
//     let tray7 = Tray(title: "MyTitle", isVisible: true)
//     let tray8 = Tray(title: "MyTitle", isVisible: true)
//     let tray9 = Tray(title: "MyTitle", isVisible: true)
//     let tray10 = Tray(title: "MyTitle", isVisible: true)
//     let tray11 = Tray(title: "MyTitle", isVisible: true)
//     let tray12 = Tray(title: "MyTitle", isVisible: true)
//     let tray13 = Tray(title: "MyTitle", isVisible: true)
//     let tray14 = Tray(title: "MyTitle", isVisible: true)
//     let tray15 = Tray(title: "MyTitle", isVisible: true)
//
//     tray1.set(title: warning + text)
//     tray2.set(title: warning)
//     tray3.set(title: text)
//     tray4.set(title: car)
//     tray5.set(title: car + text)
//     tray6.set(title: bigWarn)
//     tray7.set(title: bigWarn + bigText)
//     tray8.set(title: bigTitle.styled(with: .baselineOffset(-2)))
//     tray9.set(title: bigTitle.styled(with: .baselineOffset(0)))
//     tray10.set(title: bigTitle.styled(with: .baselineOffset(-9)))
//     tray11.set(title: bigTitle.styled(with: .baselineOffset(9)))
//     tray12.set(title: "A".styled(with: .baselineOffset(9)) + "B".styled(with: .baselineOffset(-9)))
//     tray13.set(title: warning.styled(with: .baselineOffset(9)) + "Hi!".styled(with: .baselineOffset(-9)))
//
//
//     let menu = NSMenu(title: "YYY")
//     let sub = NSMenuItem(title: "XXX", action: nil, keyEquivalent: "")
//     menu.addItem(sub)
//     tray12.set(menu: menu)
//
//
//     menus.append(menu)
//     subs.append(sub)
//
//
//     let fontawesome = NSFont(name:"FontAwesome", size: barFont.pointSize + 4)!
//     // let text2 = "hello! ABC ÖÖ".styled(with: StringStyle(.font(barFont)))
//     let awarn = ":warning:".emojified.styled(with: StringStyle(.font(fontawesome), .baselineOffset(-1)))
//
//
//
//     let bwarn =
//
//     let errorSubMenu = NSAttributedString.composed(of: [bwarn, Tab.headIndent(10), "This is a test".styled(with: .font(menuFont))])
// //    tray1.set(title: errorSubMenu)
//
//     sub.attributedTitle = errorSubMenu
//
//     // let fontawesome = NSFont(name:"FontAwesome", size: barFont.pointSize)!
//     // let textFont = NSFont.menuBarFont(ofSize: 0)
//     // let text2 = "hello! ABC ÖÖ".styled(with: StringStyle(.font(textFont)))
//     // let awarn = ":warning:".emojified.styled(with: StringStyle(.font(fontawesome)))
//     //
//     // let fontAwesomeText = NSAttributedString.composed(of: [awarn, Tab.headIndent(7), text2]).styled(with: .numberSpacing(.monospaced), // renamed in 4.0
//     // .alignment(.center), .maximumLineHeight(15), .minimumLineHeight(15))
//
//     // tray14.set(title: warning.styled(with: .baselineOffset(9), .font(bigBarFont)) + "Hi!".styled(with: .baselineOffset(-9)))
//     // var size = CGSize()
//     // size.width = 20
//     // size.height = 20
//     // tray14.set(title: awarn)
//     // let image = NSImage.fontAwesomeIconWithName(.warning, textColor: .black, size: size)
//     // tray15.set(title: "hello ".immutable + image.styled(with: .baselineOffset(-4)))
//
//     trays.append(tray1)
//     // trays.append(tray2)
//     // trays.append(tray3)
//     // trays.append(tray4)
//     // trays.append(tray5)
//     // trays.append(tray6)
//     // trays.append(tray7)
//     // trays.append(tray8)
//     // trays.append(tray9)
//     // trays.append(tray10)
//     // trays.append(tray11)
//     trays.append(tray12)
//     // trays.append(tray13)
//     // trays.append(tray14)
//     // trays.append(tray15)
//
//     // let fontURL = Bundle.main.url(forResource: "FontAwesome", withExtension: "otf"  )
//       // if let fontURL = fontURL, let data = NSData(contentsOfURL: fontURL) {
//       //     return data
//       // }j
//
//       // print("FOUND IT")
//       // print(fontURL)
// //    print(manager.defaultLineHeight(forFont: bigBarFont))
// //    print(manager.defaultLineHeightForFont(barFont))
//   }
}

func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
  return NSAttributedString.composed(of: [lhs, rhs])
}
