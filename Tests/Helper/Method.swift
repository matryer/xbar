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

//class ScriptDel: ScriptDelegate {
//  let result: (Script.Result) -> Void
//
//  init(_ block: @escaping (Script.Result) -> Void) {
//    result = block
//  }
//
//  func scriptDidReceive(success: Script.Success) {
//    result(.success(success))
//  }
//  func scriptDidReceive(failure: Script.Failure) {
//    result(.failure(failure))
//  }
//}
//
//func testSucc(_ path: String, args: [String] = [], assumed: String) {
//  var result: Script.Result?
//  var script: Script?
//  let del = ScriptDel() {
//    result = $0
//    let _ = script
//  }
//  script = Script(path: toFile(path), args: args, delegate: del, autostart: true)
//  expect(result).toEventually(beASuccess(with: assumed), timeout: 4000)
//}
//
//func testStream(_ path: String, args: [String] = [], assumed: [String]) {
////  if assumed.isEmpty { fail("Assumed can't be empty'") }
////  var index = 0
////  let del = ScriptDel() { result in
////    let description = String(describing: result)
////    if index == -1 {
////      return fail("To many calls. Max is \(assumed.count) \(path): \(description)")
////    }
////
////    if !assumed.indices.contains(index) {
////      fail("Script was called to many times. \(description)")
////      index = -1
////      return done()
////    }
////
////    expect(result).to(beASuccess(with: assumed[index]))
////
////    index += 1
////    if assumed.count == index {
////      done()
////      index = -1
////    }
////  }
////  }
//}
//
//func testFail(_ path: String, args: [String] = [], assumed: String) {
//  var output: Script.Result?
//  var script: Script?
//  let del = ScriptDel() {
//    output = $0
//    let _ = script
//  }
//  expect(output).toEventually(beAFailure(with: assumed), timeout: 4000)
//  script = Script(path: toFile(path), args: args, delegate: del, autostart: true)
//}
//
//func testEnv(path: String, env: String, value: String) {
//  var output: Script.Result?
//  var script: Script?
//  let del = ScriptDel() {
//    output = $0
//    let _ = script
//  }
//  expect(output).toEventually(have(environment: env, setTo: value), timeout: 4000)
//  script = Script(path: toFile(path), args: [], delegate: del, autostart: true)
//}
//
//func testCrash(_ path: String, args: [String] = [], assumed: String) {
//  var output: Script.Result?
//  var script: Script?
//  let del = ScriptDel() {
//    output = $0
//    let _ = script
//  }
//  expect(output).toEventually(beACrash(with: assumed), timeout: 4000)
//  script = Script(path: toFile(path), args: args, delegate: del, autostart: true)
//}
//
//func testMisuse(_ path: String, args: [String] = [], assumed: String) {
//  var output: Script.Result?
//  var script: Script?
//  let del = ScriptDel() {
//    output = $0
//    let _ = script
//  }
//  expect(output).toEventually(beAMisuse(with: assumed), timeout: 3000)
//  script = Script(path: toFile(path), args: args, delegate: del, autostart: true)
//}
