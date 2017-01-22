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
  private let tray = Tray(title: "…")
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
//      output.title.applyTo(tray: tray)
//      tray.show()
    case let Result.failure(error):
      didReceiveError(String(describing: error))
    }
  }

  /**
    Either the script failed in Script or the parser failed
    in didReceivedOutput. The output is parsed and displayed for the user
  */
  func didReceiveError(_ data: String) {
    // TODO: Implement a proper tray.set(error: ...) function
    tray.clear(title: "Error...")
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
    hide()
    // tray.hide()
    tray.destroy()
    output?.destroy()
  }
//
//  /**
//    User clicked 'Open in Terminal'
//    Opening @path in Terminal App
//    // TODO: Move logic from Bash to Terminal
//  */
//  func preferenceDidOpenInTerminal() {
//    Bash.open(script: path)
//  }
//
//  /**
//    User clicked 'Refresh All'
//  */
//  func preferenceDidRefreshAll() {
//    delegate?.preferenceDidRefreshAll()
//  }
//
//  /**
//    User clicked 'Quit'
//  */
//  func preferenceDidQuit() {
//    delegate?.preferenceDidQuit()
//  }
//
//  /**
//    User changed plugin folder
//  */
//  func preferenceDidChangePluginFolder() {
//    delegate?.preferenceDidChangePluginFolder()
//  }
}
