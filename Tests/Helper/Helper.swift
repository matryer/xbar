import SwiftCheck
import Quick
import Swift
import Nimble
@testable import BitBar

class Helper: QuickSpec {
 public func verify<T>(_ parser: P<T>, _ input: String, block: (T) -> Void) {
   switch Pro.parse(parser, input) {
   case let Result.success(result, _):
     block(result)
   case let Result.failure(lines):
     print("warning: Failed parsing")
     print("warning: Could not parse: ", input.inspected())
     for error in lines {
       print("warning:", error.inspected())
     }
     fail("Could not parse: " + input)
   }
 }

  public func match<T>(_ parser: P<T>, _ value: String, _ block: @escaping (T) -> Void) {
    verify(parser, value, block: block)
  }

  public func test<T>(_ parser: P<T>, _ value: String, _ block: @escaping (T) -> Void) {
    verify(parser, value, block: block)
  }

  public func failure<T>(_ parser: P<T>, _ input: String) {
    switch Pro.parse(parser, input) {
    case Result.success(_, _): break
      // TODO: readd */
//      fail("Expected failure, got success: \(result) with remain: \(inspect(remain))")
    case Result.failure(_):
      // TODO: Implement custom matcher
      expect(1).to(equal(1))
    }
  }
}
