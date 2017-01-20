import Cocoa

final class Bash: StringVal, ScriptDelegate {
  override func applyTo(menu: MenuDelegate) {
    menu.onDidClick {_ in
      if menu.openTerminal() {
        self.openTerminal()
      } else {
        Script(path: self.getValue(), args: menu.getArgs(), delegate: self) {
          if menu.shouldRefresh() { menu.refresh() }
        }.start()
      }
    }
  }

  internal func scriptDidReceiveOutput(_ output: String) {
    print("Received output \(output) from script \(getValue())")
  }

  internal func scriptDidReceiveError(_ error: String, _ code: Int32) {
    print("Got error \(error) with exit code \(code) when running \(getValue())")
  }

  private func openTerminal() {
    let tell =
      "tell application \"Terminal\" \n" +
      "do script \"\(getValue())\" \n" +
      "activate \n" +
      "end tell"
    guard let script = NSAppleScript(source: tell) else {
      return print("Could not parse script: \(tell)")
    }

    let errors = script.executeAndReturnError(nil)
    guard errors.numberOfItems == 0 else {
      return print("Received errors when running script \(errors)")
    }
  }
}
