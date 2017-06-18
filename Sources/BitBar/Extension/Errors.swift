import Parser
import Script

extension MenuError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .duplicate(params):
      let list = params.map(String.init(describing:))
      return "Duplicate params: \(list.join(","))"
    case let .duplicateActions(a1, a2):
      return "Duplicate actions: a1=\(a1), a2=\(a2)"
    case let .invalidSubMenuDepth(t1, t2, level):
      return "Invalid submenus t1=\(t1), t2=\(t2), level=\(level)"
    case let .invalidMenuDepth(head, tail, level):
      return "Invalid submenus head=\(head), tail=\(tail), level=\(level)"
    case let .noParamsForSeparator(params):
      let list = params.map(String.init(describing:))
      return "No params for separator: \(list.join(","))"
    case let .noSubMenusForSeparator(tails):
      let list = tails.map(String.init(describing:))
      return "No submenu for separator: \(list.join(","))"
    case let .param(key, error):
      return "Invalid param \(key): \(error)"
    case let .parseError(error):
      return "Parse error: \(error)"
    case let .argumentsSetButNotBash(args):
      return "Argument \(args.join(",")) has been set, but not bash='...'"
    case let .eventsSetButNotBash(events):
      let list = events.map(String.init(describing:))
      return "Events \(list.join(",")) has been set, but not bash='...'"
    case let .argumentsAndEventsAreSetButNotBash(args, events):
      let eventsList = events.map(String.init(describing:))
      return "Events \(eventsList.join(",")) and args \(args.join(",")) has been set, but not bash='...'"
    }
  }
}

extension ValueError: CustomStringConvertible {
  public var description: String {
    switch self {
      case let .int(value):
        return "Expected a number but got \(value.inspected())"
      case let .float(value):
        return "Expected a float but got \(value.inspected())"
      case let .image(value):
        return "Expected an image but got \(value.inspected())"
      case let .base64OrHref(value):
        return "Expected base 64 or an href but got \(value.inspected())"
      case let .font(value):
        return "Expected a font but got \(value.inspected())"
      case let .color(value):
        return "Expected a color but got \(value.inspected())"
    }
  }
}

extension Script.Failure: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .crash(message):
      return "Script crashed" + format(error: message)
    case let .exit(message, status):
      return "Script exited with a non-zero exit code \(status)" + format(error: message)
    case let .misuse(message):
      return "Invalid syntax used in script" + format(error: message)
    case .terminated:
      return "Script was manually terminated"
    case .notFound:
      return "Script or subscript not found, verify the file path"
    case .notExec:
      return "Script is not executable, did you run 'chmod +x script.sh' on it?"
    }
  }

  private func format(error: String) -> String {
    if error.trimmed().isEmpty { return "" }
    return ":\n\t" + error.trimmed().replace("\n", "\n\t\t")
  }
}
