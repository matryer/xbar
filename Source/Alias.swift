// swiftlint:disable type_name

import FootlessParser

typealias CRange = CountableClosedRange<Int>
typealias Block<T> = (T) -> Void
typealias Filter = [Paramable.Type]
// TODO: Rename to something less generic
typealias Value = (String, [Code])
/* TODO: Give these aliases a better name */
typealias X = (String, [Paramable], Int)
typealias P<T> = Parser<Character, T>
typealias U = P<X>
