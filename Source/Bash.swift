import Foundation
import EmitterKit
import Async
import FootlessParser

public func stop <A, B>(_ message: String) -> Parser<A, B> {
  return Parser { parsedtokens in
    throw ParseError.Mismatch(parsedtokens, message, "done")
  }
}

final class Bash: StringVal, Param {
  var priority = 0
  var path: String { return data }
  func menu(didLoad menu: Menuable) {
    menu.activate()
  }

  func menu(didClick menu: Menuable) {
    if menu.openTerminal() {
      Bash.open(script: path) {
        menu.add(error: $0)
      }
    }

    Script(path: path, args: menu.getArgs()) { result in
      switch result {
      case let .failure(error):
        return menu.add(error: String(describing: error))
      case .success(_):
        if menu.shouldRefresh() {
          menu.refresh()
        }
      }
    }.start()
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
