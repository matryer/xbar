import AppKit
import Swift

/**
  Base plugin responsible for delegating data to
  - the status bar
  - app delegate
  - plugin manager
*/
class Plugin {
  private let file: File
  private let path: String
  private var title: Title?
  private var output: Output?

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
      result.title.onDidRefresh { self.refresh() }
      output?.destroy()
      output = result
      title = nil
    case let Result.failure(lines):
      title = Title(errors: lines)
    }
  }

  /**
    Either the script failed in Script or the parser failed
    in didReceivedOutput. The output is parsed and displayed for the user
  */
  func didReceiveError(_ message: String) {
    title = Title(error: message)
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

  /**
    Completely removes plugin from menu bar
  */
  func destroy() {
    title?.destroy()
    output?.destroy()
  }
  deinit { destroy() }
}
