import Cocoa
import Async

// TODO: Use the delegate pattern for the
// Param protocol instead of #applyTo
// I.e bash.delegate = menu
// then in bash; delegate?.shouldRefresh()
final class Bash: StringVal {
  override func applyTo(menu: MenuDelegate) {
    menu.onDidClick {
      // TODO: Rename to shouldOpenInTerminal (or something simular)
      if menu.openTerminal() {
        return Bash.open(script: self.getValue())
      }

      Script(path: self.getValue(), args: menu.getArgs()) {
        if menu.shouldRefresh() { menu.refresh() }
      }.start()
    }
  }

  /**
    Open @script in the Terminal app
    @script is an absolute path to script
  */
  static func open(script: String) {
    // TODO: What happens if @script contains spaces?
    let tell =
      "tell application \"Terminal\" \n" +
      "do script \"\(script)\" \n" +
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
      print("Errors: \(error)")
    }
  }
}