// swiftlint:disable type_name

import FootlessParser
import Files
import Foundation

typealias Block<T> = (T) -> Void
typealias Mutable = NSMutableAttributedString
typealias Immutable = NSAttributedString
typealias P<T> = Parser<Character, T>
