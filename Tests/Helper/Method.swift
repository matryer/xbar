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

public func test(expect: Code, label: String) -> MatcherFunc<Value> {
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

 // FIXME
 return ""
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

//func testSucc(_ path: String, args: [String] = [], assumed: String) {
// waitUntil(timeout: timeout) { done in
//   _ = Script(path: toFile(path), args: args, autostart: true) { result in
//     expect(result).to(beASuccess(with: assumed))
//     done()
//   }
// }
//}

//func testStream(_ path: String, args: [String] = [], assumed: [String]) {
// if assumed.isEmpty { fail("Assumed can't be empty'") }
// var index = 0
// waitUntil(timeout: timeout) { done in
//   _ = Script(path: toFile(path), args: args, autostart: true) { result in
//     let description = String(describing: result)
//     if index == -1 {
//       return fail("To many calls. Max is \(assumed.count) \(path): \(description)")
//     }
//
//     if !assumed.indices.contains(index) {
//       fail("Script was called to many times. \(description)")
//       index = -1
//       return done()
//     }
//
//     expect(result).to(beASuccess(with: assumed[index]))
//
//     index += 1
//     if assumed.count == index {
//       done()
//       index = -1
//     }
//   }
// }
//}

//func testFail(_ path: String, args: [String] = [], assumed: String) {
// waitUntil(timeout: timeout) { done in
//   _ = Script(path: toFile(path), args: args, autostart: true) { result in
//     expect(result).to(beAFailure(with: assumed))
//     done()
//   }
// }
//}
//
//func testEnv(path: String, env: String, value: String) {
// waitUntil(timeout: timeout) { done in
//   _ = Script(path: toFile(path), args: [], autostart: true) { result in
//     expect(result).to(have(environment: env, setTo: value))
//     done()
//   }
// }
//}
//
//func testCrash(_ path: String, args: [String] = [], assumed: String) {
// waitUntil(timeout: timeout) { done in
//   _ = Script(path: toFile(path), args: args, autostart: true) { result in
//     expect(result).to(beACrash(with: assumed))
//     done()
//   }
// }
//}
//
//func testMisuse(_ path: String, args: [String] = [], assumed: String) {
// waitUntil(timeout: timeout) { done in
//   _ = Script(path: toFile(path), args: args, autostart: true) { result in
//     expect(result).to(beAMisuse(with: assumed))
//     done()
//   }
// }
//}
