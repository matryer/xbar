import Foundation

typealias CRange = CountableClosedRange<Int>
extension CountableClosedRange where Bound : Integer {
  var old: NSRange {
    let upper = upperBound as! Int
    let lower = lowerBound as! Int
    return NSRange(location: lower, length: upper - lower)
  }
}
