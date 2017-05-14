// swiftlint:disable force_cast
// swiftlint:disable type_name

import Quick
import Nimble
@testable import BitBar

let quotes =  ["\"", "'"]
let slash = "\\"
let timeout = 10.0
let bundle = Bundle(for: ExecutablePluginTests.self)

func toFile(_ path: String) -> String {
  let res = path.components(separatedBy: ".")
  return toPath(name: res[0], ext: res[1])
}

func toPath(name: String, ext: String) -> String {
  if let out = bundle.path(forResource: name, ofType: ext) {
    return out
  }

  let file = "\(name).\(ext)"
  print("[Error] !! Dont forget to add \(file) to the test target.")
  preconditionFailure("[Error] Could not find file \(file) in test target.")
}

func escape(char: String) -> String {
  let count = char.characters.count
  guard count == 1 else {
    preconditionFailure("Char length must be one, not \(count)")
  }

  // FIXME: Can we do this better?
  return char.replace(char, slash + char)
}

func escape(title: String, what: [String]) -> String {
 return ([slash] + what).reduce(title) { title, what in
   return title.replace(what, escape(char: what))
 }
}

func escape(title: String) -> String {
 return escape(title: title, what: ["|", "\n"])
}

func toQuote(_ value: String, quote: String) -> String {
 return quote + escape(value, quote) + quote
}

func escape(_ what: String, _ toEscape: String) -> String {
 return what.replace(toEscape, "\\" + toEscape)
}

func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
  return NSAttributedString.composed(of: [lhs, rhs])
}

