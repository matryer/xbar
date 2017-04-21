import SwiftCheck

extension CountableClosedRange where Iterator.Element: RandomType {
  var any: Gen<Element> {
    return Gen<Element>.fromElements(in: first!...last!)
  }
}
