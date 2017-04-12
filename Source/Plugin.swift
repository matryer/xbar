import AppKit
import Swift

/**
  Base plugin responsible for delegating data to
  - the status bar
  - app delegate
  - plugin manager
*/
class Plugin: OutputDelegate {
  private let tray = Tray(title: "…", isVisible: true)
  private let file: File
  private let path: String
  private var error: Title? {
    didSet {
      if output != nil {
        output = nil
      }
    }
  }
  private var output: Output? {
    didSet {
      if error != nil {
        error = nil
      }

      output?.delegate = self
    }
  }

  /**
    @path An absolute path to the script
    @file A file object containing {name}.{time}.{ext}
    @delegate Someone that can handle tray events, i.e 'Reload All'
  */
  init(path: String, file: File) {
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
    switch Pro.parse(Pro.getOutput(), data) {
    case let Result.success(result, _):
      if let _ = output {
        output!.title.merge(with: result.title)
      } else {
        self.output = result
      }

      output!.title.apply(to: tray)
    case let Result.failure(lines):
      self.error = Title(errors: lines)
      self.error?.apply(to: tray)
    }
  }

  /**
    Either the script failed in Script or the parser failed
    in didReceivedOutput. The output is parsed and displayed for the user
  */
  func didReceiveError(_ message: String) {
    error = Title(error: message)
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
    Triggered when user clicked 'open in terminal'
  */
  func output(didClickOpenInTerminal: Output) {
    Bash.open(script: path) { error in
      self.didReceiveError(error)
    }
  }

  /**
    Triggered when refresh was called from a menu
  */
  func output(didTriggerRefresh: Output) {
    refresh()
  }

  /**
    Completely removes plugin from menu bar
  */
  func destroy() {
    terminate()
  }
  deinit { destroy() }
}
