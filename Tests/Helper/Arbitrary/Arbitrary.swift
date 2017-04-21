import SwiftCheck
@testable import BitBar

let failed = false <?> "Parser failed"
let upper: Gen<Character> = Gen<Character>.fromElements(in: "A"..."Z")
let lower: Gen<Character> = Gen<Character>.fromElements(in: "a"..."z")
let natrual = Int.arbitrary.suchThat { $0 > 0 }
let numeric: Gen<Character> = Gen<Character>.fromElements(in: "0"..."9")
let upperAF: Gen<Character> = Gen<Character>.fromElements(in: "A"..."F")
let loweraf: Gen<Character> = Gen<Character>.fromElements(in: "a"..."f")
let hexValue = Gen<Int>.choose((1, 6)).flatMap {
  return toString(upperAF, loweraf, numeric, size: $0)
}
let special: Gen<Character> = Gen<Character>.fromElements(of:
    ["!", "#", "$", "%", "&", "*", "+", "-", "/",
      "=", "?", "^", "_", "`", "{", "}", "~", "."
])
let char: Gen<Character> = Gen<Character>.one(of: [
  lower,
  numeric,
  special,
  upper
])
let suffix = anyOf("=", "==", "")
let base64 = glue([toString(upperAF, loweraf, numeric), suffix])

func toString(_ gens: Gen<Character>..., size: Int = 3) -> Gen<String> {
  return Gen<Character>.one(of: gens).proliferateRange(1, size).map { String.init($0) }
}

func anyOf(_ values: String...) -> Gen<String> {
  return Gen<String>.one(of: values.map { Gen.pure($0) })
}

func glue(_ parts: [Gen<String>]) -> Gen<String> {
  return sequence(parts).map { $0.reduce("", +) }
}

func inspect(_ value: String) -> String {
  return "'" + value.replace("\n", "\\n").replace("'", "\\'") + "'"
}
