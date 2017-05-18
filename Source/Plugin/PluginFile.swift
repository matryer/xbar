import Foundation
import Files
import SwiftyTimer
import DateToolsSwift
import Async
import Parser

class PluginFile: NSObject, Parent, Managable {
  private let manager = FileManager.default
  internal weak var root: Parent?
  private var path: String { return file.path }
  private let file: Files.File
  internal var name: String { return file.name }
  internal let tray = Tray(title: "…", isVisible: true)
  internal var title: Title?
  private var plugin: Plugin?
  private var timer: Timer?
  private var currentIndex = -1
  private var text: [Parser.Text] = []
  private var noOfItem = 0
  private let updateInterval: Double = 10.seconds

  init(file: Files.File, delegate: Parent) {
    self.file = file
    self.root = delegate
    super.init()
    setTimer()
    setTitle()
  }

  // Called by plugin when new data has arrived
  func plugin(didReceiveOutput data: String) {
    // TODO: Empty title should be special enum
    if data.trimmed().isEmpty {
      return log(err: "Empty string passed")
    }

    Async.background {
      return reduce(data)
    }.main { [weak self] head -> Void in
      switch head {
      case let .text(text, tails):
        self?.load(text: text)
        self?.title?.set(menus: tails.map { $0.menuItem })
      case let .error(messages):
        self?.set(errors: messages)
      }
    }
  }

  // Called by plugin when an error has been raised
  func plugin(didReceiveError error: String) {
    set(errors: [error])
  }

  func refresh() {
    plugin?.refresh()
  }

  func on(_ event: MenuEvent) {
    switch event {
    case .didSetError:
      tray.set(error: true)
    case .refreshPlugin:
      refresh()
    case .runInTerminal:
      broadcast(.openPathInTerminal(path))
    default:
      break
    }
  }

  // Rotate between items in {text} every {updateInterval}
  private func load(text: [Parser.Text]) {
    self.text = text
    self.noOfItem = text.count
    if text.isEmpty { set(title: "…") }
    else { set(using: 0) }
  }

  // Set menu bar title to {text}
  private func set(text: Parser.Text) {
    tray.set(title: text.colorize(as: .bar))
  }

  // Set menu bar title to {title}
  private func set(title: String) {
    tray.set(title: title.immutable)
  }

  private func set(errors: [MenuError]) {
    log(err: "Received \(errors.count) errors as MenuError")
    set(errors: errors.map(String.init(describing:)))
  }

  private func set(errors: [String]) {
    tray.set(title: barWarn)
    title?.set(menus: errors.map { Menu(title: $0) })
  }

  // Set title to {index} in {text}
  private func set(using index: Int) {
    guard index < noOfItem else {
      return log(err: "Invalid index: \(index), max is \(noOfItem)")
    }

    guard currentIndex != index else {
      return log(ver: "Index has not change from \(index), wont update title")
    }

    guard currentIndex == -1 || noOfItem > 0 else {
      return log(ver: "No items to update")
    }

    currentIndex = index
    set(text: text[currentIndex])
  }


  // Set title to next item in {text}
  private func setNext() {
    set(using: (currentIndex + 1) % noOfItem)
  }

  private var type: String {
    return plugin?.type ?? "Undefined"
  }

  private var defaultPrefs: [String: String] {
    return plugin?.meta ?? [:]
  }

  // Printable path to script
  private var dir: String {
    return file.path.replace(home, "~/").remove("/" + file.name)
  }

  // Absolute path to home dir
  private var home: String {
    return FileSystem().homeFolder.path
  }

  // Sub menu containing details about the plugin
  private var pref: MenuItem {
    return MenuItem(title: "Plugin Details", submenus: prefs)
  }

  private var prefs: [MenuItem] {
    return metadata + [
      "Type": type,
      "File": name
    ].map { meta in
      return MenuItem(title: meta.0 + ": " + meta.1)
    } + defaultPrefs.map { meta in
      return MenuItem(title: meta.0 + ": " + meta.1)
    } + [
      Pref.FirstRun(),
      MenuItem(title: "Path: \(dir)"),
      MenuItem(title: "Is Executable: \(isExec)"),
      MenuItem(title: "Is Readable: \(isReadable)"),
      MenuItem(title: "Cycle updates: \(Int(updateInterval)) sec")
    ]
  }

  private var metadata: [MenuItem] {
    do {
      return try Metadata.from(path: file.path).map {
        return MenuItem(title: String(describing: $0))
      }
    } catch {
      return []
    }
  }

  private var isExec: String {
    return manager.isExecutableFile(atPath: file.path) ? "Yes" : "No"
  }

  private var isReadable: String {
    return manager.isReadableFile(atPath: file.path) ? "Yes" : "No"
  }

  private func log(msg: String) {
    print("[Log] [\(name)] \(msg)")
  }

  private func log(err: String) {
    print("[Err] [\(name)] \(err)")
  }

  // Verbose logger, disabled by default
  private func log(ver: String) {
    // print("[Ver] [\(name)] \(ver)")
  }

  private func setTimer() {
    timer = Timer.new(every: updateInterval) { [weak self] in self?.setNext() }
    timer?.start(modes: .defaultRunLoopMode, .eventTrackingRunLoopMode)
  }

  // TODO: Move to test
  var hasLoaded: Bool {
    return title?.hasLoaded ?? false
  }

  private func setTitle() {
    do {
      plugin = try File.toPlugin(file: file, delegate: self)
      title = Title(prefs: [pref], delegate: self)
    } catch let error {
      title = Title(prefs: [pref], delegate: self)
      set(errors: [String(describing: error)])
    }

    tray.menu = title!
  }
}
