import SwiftCheck
@testable import BitBarParser

func toString(_ gens: Gen<Character>..., size: Int = 3) -> Gen<String> {
  return Gen<Character>.one(of: gens).proliferateRange(1, size).map { String.init($0) }
}
let low: Gen<Character> = Gen<Character>.fromElements(in: "a"..."z")
let up: Gen<Character> = Gen<Character>.fromElements(in: "A"..."Z")
let numeric: Gen<Character> = Gen<Character>.fromElements(in: "0"..."9")
let upperAF: Gen<Character> = Gen<Character>.fromElements(in: "A"..."F")
let loweraf: Gen<Character> = Gen<Character>.fromElements(in: "a"..."f")
let ascii = toString(low, up, numeric)
let hexValue: Gen<String> = Gen<Int>.choose((1, 6)).flatMap {
  return toString(upperAF, loweraf, numeric, size: $0)
}
let string = String.any(min: 1, max: 15)
let natural = Int.arbitrary.suchThat { $0 > 0 }
let small = Int.arbitrary.suchThat { $0 >= 0 && $0 <= 500 }
let float = Gen<(Int, Int)>.zip(small, small).map {
  return Float("\($0).\($1)")!
}
let bool = Bool.arbitrary

func ==== <T: Arbable>(lhs: [T], rhs: [T]) -> Property {
  return lhs.enumerated().reduce(true <?> "list") { (acc, x) in
    guard let el2 = rhs.get(at: x.0) else {
      return false <?> "\(x.1) not found at index \(x.0)"
    }

    return acc ^&&^ (x.1 ==== el2)
  }
}

let special: Gen<Character> = Gen<Character>.fromElements(of:
  ["-", ".", "_", "~", ":", "/", "?", "#",
  "[", "]", "@", "!", "$", "&", "'", "(", ")", "*", "+", ",", ";"
])

let char: Gen<Character> = Gen<Character>.one(of: [
  low,
  numeric,
  special,
  up
])

let url = Gen<(String, String, String, String)>.zip(ascii, ascii, string, string).map { "http://\($0).\($1))/\($2.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)/\($3.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)" }
