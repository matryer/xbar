import Foundation

extension NSRange {
  var new: CountableClosedRange<Int> {
    return location...(location + length)
  }
}
