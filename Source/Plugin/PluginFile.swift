import Foundation
import Files
import DateToolsSwift
import Async
import Parser

class PluginFile: NSObject, Parent, Managable {
  internal weak var root: Parent?
  private let file: Files.File
  internal var name: String { return file.name }
  internal let tray = Tray(title: "…", isVisible: true)
  internal var title: Title?
  private var plugin: Plugin?

  init(file: Files.File, delegate: Parent) {
    self.file = file
    super.init()

    do {
      plugin = try File.toPlugin(file: file, delegate: self)
      title = Title(prefs: [pref], delegate: self)
    } catch let error {
      title = Title(prefs: [pref], delegate: self)
      set(errors: [String(describing: error)])
    }

    self.root = delegate
    tray.menu = title!
  }

  func plugin(didReceiveOutput data: String) {
    if data.trimmed().isEmpty {
      return print("[Log] Empty string passed from \(plugin?.name ?? "no plugin")")
    }

    Async.background {
      return reduce(data)
    }.main { [weak self] head -> Void in
      switch head {
      case let .text(text, tails):
        self?.tray.set(title: text.colorize(as: .bar))
        self?.title?.set(menus: tails.map { $0.menuItem })
      case let .error(messages):
        self?.set(errors: messages)
      }
    }
  }

  var hasLoaded: Bool {
    return title?.hasLoaded ?? false
  }

  func plugin(didReceiveError error: String) {
    set(errors: [error])
  }

  private func set(errors: [String]) {
    tray.set(title: barWarn)
    title?.set(menus: errors.map { Menu(title: $0) })
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
    default:
      break
    }
  }

  private var type: String {
    return plugin?.type ?? "Undefined"
  }

  private var defaultPrefs: [String: String] {
    return plugin?.meta ?? [:]
  }

  private var dir: String {
    return file.path.replace(home, "~/").remove("/" + file.name)
  }

  private var home: String {
    return FileSystem().homeFolder.path
  }

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
    } + [Pref.FirstRun(), MenuItem(title: "Path: " + dir)]
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
}
