// swiftlint:disable force_cast
// swiftlint:disable type_name

import Quick
import Nimble
import SwiftCheck
@testable import BitBar

let quotes =  ["\"", "'"]
let slash = "\\"
let timeout = 10.0
// TODO: Rename to something more descriptive

public func tester<T>(_ post: String..., block: @escaping (T) -> Any) -> MatcherFunc<T> {
 return MatcherFunc { actual, failure in
   failure.postfixMessage = post.joined(separator: " ")
   guard let result = try actual.evaluate() else {
     return false
   }

   let out = block(result)
   switch out {
   case is String:
     failure.postfixActual = out as! String
     return false
   case is Bool:
     return out as! Bool
   default:
     preconditionFailure("Invalid data, expected String or Bool got \(type(of: out))")
   }
 }
}

enum Test<T: Equatable> {
   case succ
   case fail
   /* Exp, Actual */
   case comp(T, T)
   case test(Bool)
}

func t<T, A: Equatable>(_ title: String, block: @escaping (T) -> Test<A>) -> MatcherFunc<T> {
  return MatcherFunc { actual, failure in
    failure.expected = "expected \(title)"
    guard let result = try actual.evaluate() else {
      return false
    }

    let succ = {
      failure.postfixMessage = "succeed"
      failure.actualValue = "an unknown success"
    }

    let fail = {
      failure.postfixMessage = "succeed"
      failure.actualValue = "an unknown failure"
    }

    switch block(result) {
    case .succ:
      succ()
      return true
    case let .comp(expected, actual):
      failure.postfixMessage = "equal \(String(describing: expected).inspected())"
      failure.actualValue = String(describing: actual).inspected()
      return actual == expected
    case .fail:
      fail()
      return false
    case .test(true):
      succ()
      return true
    case .test(false):
      fail()
      return false
    }
  }
}


func test(expect: Code, label: String) -> MatcherFunc<Value> {
   return tester(label) { (_, codes) in
     for actual in codes {
       if actual == expect {
         return true
       }
     }

     return "not " + label
   }
 }

func toFile(_ path: String) -> String {
  let res = path.components(separatedBy: ".")
  if let out = Bundle(for: Helper.self).path(forResource: res[0], ofType: res[1]) {
    return out
  }

  preconditionFailure("Could not find file \(res.joined(separator: "."))")
}

// -- dex
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
