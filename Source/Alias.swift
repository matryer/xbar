import FootlessParser

typealias CRange = CountableClosedRange<Int>
/* TODO: Give these aliases a better name */
typealias X = (String, [Paramable], Int)
public typealias P<T> = Parser<Character, T>
typealias U = P<X>