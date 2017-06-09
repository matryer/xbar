import Foundation
import Files
import SwiftyTimer
import DateToolsSwift
import SwiftyBeaver
import Async
import Parser
import Vapor

final class PluginFile: NSObject, Parent, Managable, Parameterizable, JSONRepresentable {
  private let manager = FileManager.default
  private let storage = Storage()
  internal let log = SwiftyBeaver.self
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
  internal var hasLoaded = false
  private var storageList = [String]()

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
      return set(errors: ["Empty output returned from script"])
    } else {
      log(msg: "Received success from background script (below)")
      log(msg: data.inspected())
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

      self?.hasLoaded = true
    }
  }

  func hide() {
    tray.hide()
    plugin?.stop()
    log(msg: "Set to hidden")
  }

  func show() {
    tray.show()
    plugin?.start()
    log(msg: "Set to visible")
  }

  func get(_ key: String, default value: String) -> String {
    return storage.get(key, default: value)
  }

  func set(_ key: String, value: String) {
    storage.set(key, value: value)
  }

  func list() -> [String] {
    return storageList
  }

  func push(toList value: String) {
    return storageList.append(value)
  }

  func clearList() {
    storageList = []
  }

  // Called by plugin when an error has been raised
  func plugin(didReceiveError error: String) {
    log(err: "Received error \(error.inspected()) from script")
    set(errors: [error])
  }

  func refresh() {
    plugin?.refresh()
    log(msg: "Refresh")
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
    log(msg: "Rotate between \(text.count) item(s) every \(updateInterval) seconds")
    self.text = text
    self.noOfItem = text.count
    self.currentIndex = -1
    if text.isEmpty { set(title: "…") } else { set(using: 0) }
  }

  // Set menu bar title to {text}
  private func set(text: Parser.Text) {
    let string = String(describing: text).inspected()
    log(ver: "Set title to \(string)")
    tray.set(title: text.colorize(as: .bar))
  }

  // Set menu bar title to {title}
  private func set(title: String) {
    log(msg: "Set title to \(title.inspected())")
    tray.set(title: title)
  }

  private func set(errors: [MenuError]) {
    log(err: "Received \(errors.count) errors as MenuError")
    set(errors: errors.map(String.init(describing:)))
  }

  private func set(errors: [String]) {
    tray.set(error: true)
    title?.set(menus: errors.map { Menu(error: $0) })
  }

  // Set title to {index} in {text}
  private func set(using index: Int) {
    guard index < noOfItem else {
      return log(err: "Invalid index: \(index), max is \(noOfItem)")
    }

    guard currentIndex != index else { return }

    guard currentIndex == -1 || noOfItem > 0 else {
      return log(ver: "No items to update")
    }

    currentIndex = index
    set(text: text[currentIndex])
  }

  // Set title to next item in {text}
  private func setNext() {
    guard noOfItem > 0 else { return }
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
    return metadata + info.map { meta in
      return MenuItem(title: meta.0 + ": " + meta.1)
    } + defaultPrefs.map { meta in
      return MenuItem(title: meta.0 + ": " + meta.1)
    } + [
      Pref.FirstRun()
    ]
  }

  var info: [String: String] {
    return [
      "Type": type,
      "File": name,
      "Path": dir,
      "Is Executable": isExec,
      "Is Readable": isReadable,
      "Cycle updates": "\(Int(updateInterval)) sec"
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
    log.info("[\(name)] " + msg)
  }

  private func log(err msg: String) {
    log.error("[\(name)] " + msg)
  }

  private func log(ver msg: String) {
    log.verbose("[\(name)] " + msg)
  }

  private func setTimer() {
    timer = Timer.new(every: updateInterval) { [weak self] in self?.setNext() }
    timer?.start(modes: .defaultRunLoopMode, .eventTrackingRunLoopMode)
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

  func invoke(_ args: [String]) {
    plugin?.invoke(args)
    log(msg: "Invoked plugin with \(args.join(", "))")
  }

  func makeJSON() throws -> JSON {
    return try JSON(node: info)
  }

  static var uniqueSlug: String {
    return "plugin"
  }

  static func make(for name: String) throws -> PluginFile {
    if let plugin = PluginManager.instance.findPlugin(byName: name) {
      return plugin
    }

    throw Abort.notFound
  }
}
