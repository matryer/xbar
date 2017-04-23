import Foundation
import Async

final class Bash: Param<String> {
  var path: String { return value }
  override var original: String {
    return escape(raw)
  }

  override var before: Filter {
    return [Refresh.self, Terminal.self]
  }

  override func menu(didLoad menu: Menuable) {
    menu.activate()
  }

  override func menu(didClick menu: Menuable) {
    guard menu.openInTerminal else { return }

    Bash.open(script: path) { error in
      menu.add(error: error)
    }
  }

  override func menu(didClick menu: Menuable, done: @escaping (String?) -> Void) {
    guard !menu.openInTerminal else { return done(nil) }

    Script(path: path, args: menu.args) { result in
      App.notify(.bashScriptFinished(result))

      switch result {
      case let .failure(error):
        done(String(describing: error))
      case .success(_):
        done(nil)
      }
    }.start()
  }

  /**
    Open @script in the Terminal app
    @script is an absolute path to script
  */
  static func open(script path: String, block: @escaping Block<String>) {
    // TODO: What happens if @script contains spaces?
    let tell =
      "tell application \"Terminal\" \n" +
      "do script \"\(path)\" \n" +
      "activate \n" +
      "end tell"

    Async.background {
      guard let script = NSAppleScript(source: tell) else {
        return "Could not parse script: \(tell)"
      }

      App.notify(.bashScriptOpened(path))
      if App.isInTestMode() { return nil }

      let errors = script.executeAndReturnError(nil)
      guard errors.numberOfItems == 0 else {
        return "Received errors when running script \(errors)"
      }

      return nil
    }.main { (error: String?) in
      if let message = error {
        block(message)
      }
    }
  }
}
