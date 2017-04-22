// swiftlint:disable type_name

import FootlessParser

typealias CRange = CountableClosedRange<Int>
typealias Block<T> = (T) -> Void
/* TODO: Give these aliases a better name */
typealias X = (String, [Paramable], Int)
typealias P<T> = Parser<Character, T>
typealias U = P<X>
