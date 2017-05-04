// swiftlint:disable type_name

import FootlessParser

typealias CRange = CountableClosedRange<Int>
typealias Block<T> = (T) -> Void
typealias Value = (String, [Code])
typealias Mutable = NSMutableAttributedString
typealias P<T> = Parser<Character, T>
