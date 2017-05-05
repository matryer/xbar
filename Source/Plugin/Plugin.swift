import Parser
import Async

/**
  Base plugin responsible for delegating data to
  - the status bar
  - app delegate
  - plugin manager
*/
class Plugin: Eventable {
  private let tray: Tray
  internal let file: File
  internal let path: String
  private var error: Title?
  private var title: Title?

  /**
    @path An absolute path to the script
    @file A file object containing {name}.{time}.{ext}
    @delegate Someone that can handle tray events, i.e 'Reload All'
  */
  init(path: String, file: File) {
    self.tray = Tray(title: "…", isVisible: true)
    self.file = file
    self.path = path
  }

  /**
    How often the plugin should in seconds
  */
  var interval: Double {
    return Double(file.interval)
  }

  /**
    Script ran successfully in super class
    Will parse data and populate the menu bar
  */
  func didReceivedOutput(_ data: String) {
    Async.userInitiated {
      return data
    }.background { data in
      return reduce(data)
    }.main { head -> Void in
      self.use(title: Title(head: head))
    }
  }

  /**
    Either the script failed in Script or the parser failed
    in didReceivedOutput. The output is parsed and displayed for the user
  */
  func didReceiveError(_ message: String) {
    use(title: Title(error: message))
  }

  func didClickOpenInTerminal() {
    App.openScript(inTerminal: path) { error in
      if let anError = error {
        print("[Error] Received error opening \(self.path): \(anError)")
      }
    }
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

  private func use(title: Title) {
    tray.set(title: title)
    title.parentable = self
    self.title = title
  }

  func didTriggerRefresh() {
    refresh()
  }

  deinit { destroy() }

  func didSetError() {
    tray.didSetError()
  }
}
