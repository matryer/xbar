import Foundation
import EmitterKit
import Async

import FootlessParser

// public func oneOrMoreX <T,A> (_ p: Parser<T,A>) -> Parser<T,[A]> {
//   return Parser { input in
//     var (first, remainder) = try p.parse(input)
//     var result = [first]
//     while true {
//       do {
//         let next = try p.parse(remainder)
//         result.append(next.output)
//         remainder = next.remainder
//       } catch {
//         return (result, remainder)
//       }
//     }
//   }
// }
//
// public func eofx <T> () -> Parser<T,()> {
//   return Parser { input in
//     if let next = input.first {
//       throw ParseError.Mismatch(input, "EOF", String(describing:next))
//     }
//     return ((), input)
//   }
// }
//
// public func satisfy2<A, B>
//   (expect: @autoclosure @escaping () -> String, condition: @escaping ([A]) -> Bool) -> Parser<A, B> {
//   return Parser { input in
//     if condition(input) {
//       return (next, input)
//     } else {
//         throw ParseError.Mismatch(input, expect(), String(describing:next))
//     }
//   }
// }
//
public func stop <A, B>(_ message: String) -> Parser<A, B> {
  return Parser { parsedtokens in
    throw ParseError.Mismatch(parsedtokens, message, "done")
//    return fail(.Mismatch(AnyCollection(parsedtokens), message, "done"))
  }
}

// TODO: Use the delegate pattern for the
// Param protocol instead of #applyTo
// I.e bash.delegate = menu
// then in bash; delegate?.shouldRefresh()
final class Bash: StringVal, Param {
  var priority = 0
  var path: String { return value }
  func menu(didLoad menu: Menuable) {
    if menu.openTerminal() {
      menu.activate()
    }
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
