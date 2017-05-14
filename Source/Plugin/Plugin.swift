import Parser
import Async

/**
  Base plugin responsible for delegating data to
  - the status bar
  - app delegate
  - plugin manager
*/
class Plugin: NSObject, Parent {
  weak var root: Parent?
  private let file: File
  internal var path: String { return file.path }
  internal var name: String { return file.script }
  internal var interval: Double { return file.interval }
  internal var title: Title?
  private let tray: Tray

  /**
    @path An absolute path to the script
    @file A file object containing {name}.{time}.{ext}
    @delegate Someone that can handle tray events, i.e 'Reload All'
  */
  init(path: String, file: File, item: MenuBar = Tray.item) {
    self.tray = Tray(title: "…", isVisible: true, item: item)
    self.file = file
    super.init()
    self.tray.root = self
  }

  /**
    Script ran successfully in super class
    Will parse data and populate the menu bar
  */
  func didReceivedOutput(_ data: String) {
    if data.trimmed().isEmpty {
      return print("[Log] Empty string passed")
    }

    Async.background {
      return reduce(data)
    }.main { [weak self] head -> Void in
      self?.use(title: Title(head: head))
    }
  }

  /**
    Either the script failed in Script or the parser failed
    in didReceivedOutput. The output is parsed and displayed for the user
  */
  func didReceiveError(_ message: String) {
    use(title: Title(error: message))
  }

  /**
    To be implemented by the super class
    Maybe there's a better to do this?
  */
  func refresh() {
    preconditionFailure("This method must be overridden")
  }

  func show() {
    preconditionFailure("This method must be overridden")
  }

  func hide() {
    preconditionFailure("This method must be overridden")
  }

  func terminate() {
    preconditionFailure("This method must be overridden")
  }

  /**
    Completely removes plugin from menu bar
  */
  func destroy() {
    terminate()
  }
  deinit { destroy() }

  func on(_ event: MenuEvent) {
    switch event {
    case .runInTerminal:
      broadcast(.openScriptInTerminal(path))
    case .refreshPlugin:
      refresh()
    default:
      break
    }
  }

  private func use(title: Title) {
    tray.set(title: title)
    title.root = tray
    self.title = title
  }
}
