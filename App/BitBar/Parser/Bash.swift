import Cocoa
import EmitterKit
import Async

// TODO: Use the delegate pattern for the
// Param protocol instead of #applyTo
// I.e bash.delegate = menu
// then in bash; delegate?.shouldRefresh()
final class Bash: StringVal, Param {
  var priority: Int { return 0 }
  var listener: Listener?
  
  func applyTo(menu: Menuable) {
    listener = menu.onDidClick {
      // TODO: Rename to shouldOpenInTerminal (or something similar)
      if menu.openTerminal() {
        Bash.open(script: self.getValue()) {
          menu.add(error: $0)
        }
      }

      Script(path: self.getValue(), args: menu.getArgs()) { _ in
        if menu.shouldRefresh() {
          menu.refresh()
        }
      }.start()
    }
  }

  /**
    Open @script in the Terminal app
    @script is an absolute path to script
  */
  static func open(script path: String, block: @escaping Block<String>) {
    if App.isInTestMode() { return }

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
