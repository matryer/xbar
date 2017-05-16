import FootlessParser
import Foundation
import Dollar

enum Metadata {
  private static let start = "<bitbar."
  internal static var parser: P<[Metadata]> {
    let trash = til(start, allowEmpty: true, consume: false)
    return oneOrMore(trash *> item <* trash)
  }

  public enum Result {
    case failure([String])
    case success([Metadata])
  }

  public static func parse(_ value: String) -> Result {
    do {
      return Result.success(try FootlessParser.parse(parser, value))
    } catch ParseError<Character>.Mismatch(let remainder, let expected, let actual) {
      let index = value.index(value.endIndex, offsetBy: -Int(remainder.count))
      let (lineRange, row, pos) = position(of: index, in: value)
      let line = value[lineRange.lowerBound..<lineRange.upperBound].trimmingCharacters(in: CharacterSet.newlines)
      var lines = [String]()
      lines.append("An error occurred when parsing this line:")
      lines.append(line)
      lines.append(String(repeating: " ", count: pos) + "^")
      lines.append("\(row):\(pos) Expected '\(expected)', actual '\(actual)'")
      return Result.failure(lines)
    } catch (let error) {
      return Result.failure([String(describing: error)])
    }
  }

  private static func position(of index: String.CharacterView.Index, in string: String) -> (line: Range<String.CharacterView.Index>, row: Int, pos: Int) {
    var head = string.startIndex..<string.startIndex
    var row = 0
    while head.upperBound < index {
        head = string.lineRange(for: head.upperBound..<head.upperBound)
        row += 1
    }
    return (head, row, string.distance(from: head.lowerBound, to: index))
  }

  private static var item: P<Metadata> {
    return string(start) *> til(">") >>- { type in
      return til("</bitbar.\(type)>", allowEmpty: true) >>- { value in
        if let metadata = Metadata(key: type, value: value) {
          return pure(metadata)
        }
        return stop("Could not find any type matching \(type) & \(value)")
      }
    }
  }

  private static func til(_ value: String, allowEmpty: Bool = false, consume: Bool = true) -> P<String> {
    let none = noneOf([value])
    let par = allowEmpty ? zeroOrMore(none) : oneOrMore(none)

    if consume {
      return par <* optional(string(value))
    }

    return par
  }

  private static func stop<A, B>(_ message: String) -> Parser<A, B> {
    return Parser { parsedtokens in
      throw ParseError.Mismatch(parsedtokens, message, "done")
    }
  }

  case about(URL)
  case image(URL)
  case title(String)
  case github(String)
  case author(String)
  case version(String)
  case description(String)
  case dependencies([String])
  case dropTypes([String])
  case demoArgs([String])
  init?(key: String, value: String) {
    switch key.lowercased() {
    case "title":
      self = .title(value)
    case "version":
      self = .version(value)
    case "author.github":
      self = .github(value)
    case "author":
      self = .author(value)
    case "desc":
      self = .description(value)
    case "image":
      if let url = URL(string: value) {
        self = .image(url)
      } else {
        return nil
      }
    case "dependencies":
      self = .dependencies(value.split(delimiter: ","))
    case "droptypes":
      self = .dropTypes(value.split(delimiter: ","))
    case "demo":
      // TODO: Handle arbitrary whitespace
      self = .demoArgs(value.split(delimiter: " "))
    case "abouturl":
      if let url = URL(string: value) {
        self = .about(url)
      } else {
        return nil
      }
    default:
      return nil
    }
  }
}
