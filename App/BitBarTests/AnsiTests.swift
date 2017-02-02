import Quick
import Nimble
@testable import BitBar

private extension String {
  func blink(_ speed: Speed) -> String {
    switch speed {
    case .slow:
      return toAnsi(using: 5)
    case .rapid:
      return toAnsi(using: 6)
    case .none:
      return toAnsi(using: 25)
    }
  }

  var italic: String {
    return toAnsi(using: 3)
  }

  var bold: String {
    return toAnsi(using: 1)
  }

  var black: String {
    return toAnsi(using: 30)
  }

  var red: String {
    return toAnsi(using: 31)
  }

  var green: String {
    return toAnsi(using: 32)
  }

  var yellow: String {
    return toAnsi(using: 33)
  }
  var blue: String {
    return toAnsi(using: 34)
  }

  var magenta: String {
    return toAnsi(using: 35)
  }

  var cyan: String {
    return toAnsi(using: 36)
  }

  var white: String {
    return toAnsi(using: 37)
  }

  func toAnsi(using code: Int, reset: Bool = true) -> String {
    let code = "\033[\(code)m\(self)"
    if reset { return code + "\033[0m" }
    return code
  }
}

// Helper function
public func tester<T>(_ post: String, block: @escaping (T) -> Any) -> MatcherFunc<T> {
  return MatcherFunc { actual, failure in
    failure.postfixMessage = post
    guard let result = try actual.evaluate() else {
      return false
    }

    let out = block(result)
    switch out {
    case is String:
      failure.postfixActual = out as! String
      return false
    case is Bool:
      return out as! Bool
    default:
      preconditionFailure("Invalid data, expected String or Bool got (type(of: out))")
    }
  }
}

// expect("ABC".bold).to(beItalic())
public func beItalic() -> MatcherFunc<Value> {
  return test(expect: .italic(true), label: "italic")
}

// expect("ABC".bold).to(beBold())
public func beBold() -> MatcherFunc<Value> {
  return test(expect: .bold(true), label: "bold")
}

// Helper function
public func test(expect: Code, label: String) -> MatcherFunc<Value> {
  return tester(label) { (_, codes) in
    for actual in codes {
      if actual == expect {
        return true
      }
    }

    return "not " + label
  }
}

// expect("ABC").to(have(color: 10))
public func have(color actual: Int) -> MatcherFunc<Value> {
  return test(expect: .color(.foreground, .index(actual)), label: "256 color")
}

// expect("ABC").to(have(background: 10))
public func have(background actual: Int) -> MatcherFunc<Value> {
  return test(expect: .color(.background, .index(actual)), label: "256 background color")
}

// expect("ABC").to(have(background: [10, 20, 30]))
public func have(background colors: [Int]) -> MatcherFunc<Value> {
  if colors.count != 3 { preconditionFailure("Rgb must contain 3 ints") }
  let expect: Code = .color(.background, .rgb(colors[0], colors[1], colors[2]))
  return test(expect: expect, label: "RGB background color")
}

// expect("ABC").to(have(rgb: [10, 20, 30]))
public func have(rgb colors: [Int]) -> MatcherFunc<Value> {
  if colors.count != 3 { preconditionFailure("Rgb must contain 3 ints") }
  let expect: Code = .color(.foreground, .rgb(colors[0], colors[1], colors[2]))
  return test(expect: expect, label: "RGB foreground color")
}

// expect("ABC").to(haveNoStyle())
public func haveNoStyle() -> MatcherFunc<Value> {
  return tester("no style") { (_, codes) in
    return codes.isEmpty
  }
}

// expect("ABC".blink).to(blink())
public func blink(_ speed: Speed) -> MatcherFunc<Value> {
  return test(expect: .blink(speed), label: "blink")
}

// expect("ABC").to(haveUnderline())
public func haveUnderline() -> MatcherFunc<Value> {
  return test(expect: .underline(true), label: "underline")
}

// expect(result[0]).to(equal("ABC"))
public func equal(_ exp1: String) -> MatcherFunc<Value> {
  return tester("equal \(exp1)") { (exp2, _) in
    return exp1 == exp2
  }
}

// expect("ABC".red).to(be(.red))
public func be(_ color: CColor) -> MatcherFunc<Value> {
  return test(expect: .color(.foreground, color), label: "color")
}

// expect("ABC".background(color: .red)).to(have(background: .red))
public func have(background color: CColor) -> MatcherFunc<Value> {
  return test(expect: .color(.background, color), label: "color")
}

class AnsiTests: Helper {
  override func spec() {
    let check = { (_ input: String, block: @escaping ([Value]) -> Void) in
      self.test(Pro.getANSIs(), input, block)
    }

    let failing = { input in
      self.failure(Pro.getANSIs(), input)
    }

    it("handles reset") {
      check("ABC\\e[3;4;33mDEF\\e[0mGHI") { result in
        expect(result).to(haveCount(3))

        expect(result[0]).to(equal("ABC"))
        expect(result[0]).to(haveNoStyle())

        expect(result[1]).to(beItalic())
        expect(result[1]).to(equal("DEF"))
        expect(result[1]).to(haveUnderline())
        expect(result[1]).to(be(.yellow))

        expect(result[2]).to(equal("GHI"))
        expect(result[2]).to(haveNoStyle())
      }
    }

    it("handles multiply colors") {
      check("A".blue + "N".green + "S".red + "I".yellow) { result in
        expect(result).to(haveCount(4))

        expect(result[0]).to(equal("A"))
        expect(result[0]).to(be(.blue))

        expect(result[1]).to(equal("N"))
        expect(result[1]).to(be(.green))
        expect(result[1]).notTo(be(.blue))

        expect(result[2]).to(equal("S"))
        expect(result[2]).to(be(.red))
        expect(result[2]).notTo(be(.green))

        expect(result[3]).to(equal("I"))
        expect(result[3]).to(be(.yellow))
        expect(result[3]).notTo(be(.red))
      }
    }

    it("handles non ansi string") {
      check("ABC") { result in
        expect(result).to(haveCount(1))
        expect(result[0]).to(haveNoStyle())
      }
    }

    it("handles ansi without content") {
      check("\033[5m") { result in
        expect(result).to(haveCount(0))
      }
    }

    context("blink") {
      it("blinks slow") {
        check("X".blink(.slow)) { result in
          expect(result).to(haveCount(1))
          expect(result[0]).to(blink(.slow))
        }
      }

      it("blinks slow then fast") {
        check("X".blink(.slow) + "P".blink(.rapid)) { result in
          expect(result).to(haveCount(2))
          expect(result[0]).to(blink(.slow))
          expect(result[0]).to(equal("X"))

          expect(result[1]).to(blink(.rapid))
          expect(result[1]).to(equal("P"))
        }
      }

      it("blinks slow then fast, then nothing") {
        check("X".blink(.slow) + "P".blink(.rapid) + "Y".blink(.none)) { result in
          expect(result).to(haveCount(3))
          expect(result[0]).to(blink(.slow))
          expect(result[0]).to(equal("X"))

          expect(result[1]).to(blink(.rapid))
          expect(result[1]).to(equal("P"))

          expect(result[2]).to(blink(.none))
          expect(result[2]).to(equal("Y"))
        }
      }

      it("handles empty string") {
        check("") { result in
          expect(result).to(beEmpty())
        }
      }
    }

    context("bold") {
      it("handles string with space") {
        check("A B C".bold) { result in
          expect(result).to(haveCount(1))
          expect(result[0]).to(equal("A B C"))
          expect(result[0]).to(beBold())
        }
      }

      it("handles empty string") {
        check("".bold) { result in
          expect(result).to(haveCount(0))
        }
      }

      it("can combine underline with bold") {
        check("BOLD".bold + " " + "ITALIC".italic) { result in
          expect(result).to(haveCount(3))
          expect(result[0]).to(equal("BOLD"))
          expect(result[0]).to(beBold())

          expect(result[1]).to(equal(" "))
          expect(result[1]).to(haveNoStyle())

          expect(result[2]).to(equal("ITALIC"))
          expect(result[2]).to(beItalic())
          expect(result[2]).notTo(beBold())
        }
      }
    }

    context("foreground (38)") {
      context("256 color on the form ESC[38;5;<fgcode>m") {
        it("handles base case") {
          check("\033[38;5;150mX") { result in
            expect(result).to(haveCount(1))
            expect(result[0]).to(have(color: 150))
            expect(result[0]).to(equal("X"))
          }
        }

        it("fails on to few args") {
          failing("\033[38;150mX")
        }
      }

      context("rgb color on the form ESC[38;2;r;g;bm") {
        it("handles base case") {
          check("\033[38;2;10;20;30mX") { result in
            expect(result).to(haveCount(1))
            expect(result[0]).to(have(rgb: [10, 20, 30]))
            expect(result[0]).to(equal("X"))
          }
        }

        it("fails on to few args") {
          failing("\033[38;2;10;30mX")
        }
      }
    }

    context("reset") {
      it("can reset the background without altering the foreground") {
        let resetBackground = "\033[49m"
        // 40, 30 == black
        let a1 = "ABC".toAnsi(using: 40, reset: false) // background
        let a2 = "DEF".toAnsi(using: 30, reset: false) // foreground
        check(a1 + a2 + resetBackground + "A") { result in
          expect(result).to(haveCount(3))
          expect(result[0]).to(have(background: .black))

          expect(result[1]).to(be(.black))
          expect(result[1]).to(have(background: .black))

          expect(result[2]).toNot(have(background: .black))
          expect(result[2]).to(be(.black))
        }
      }

      it("can reset the foreground without altering the background") {
        let resetForeground = "\033[39m"
        let a1 = "ABC".toAnsi(using: 30, reset: false) // background
        let a2 = "DEF".toAnsi(using: 40, reset: false) // foreground
        check(a1 + a2 + resetForeground + "A") { result in
          expect(result).to(haveCount(3))
          expect(result[0]).to(be(.black))

          expect(result[1]).to(be(.black))
          expect(result[1]).to(have(background: .black))

          expect(result[2]).toNot(be(.black))
          expect(result[2]).to(have(background: .black))
        }
      }

      it("can reset everything") {
        let reset = "\033[0m"
        let a1 = "ABC".toAnsi(using: 30, reset: false) // background
        let a2 = "DEF".toAnsi(using: 40, reset: false) // foreground
        check(a1 + a2 + reset + "A") { result in
          expect(result).to(haveCount(3))
          expect(result[0]).to(be(.black))

          expect(result[1]).to(be(.black))
          expect(result[1]).to(have(background: .black))

          expect(result[2]).toNot(be(.black))
          expect(result[2]).toNot(have(background: .black))
        }
      }
    }

    context("foreground (48)") {
      context("256 color on the form ESC[48;5;<fgcode>m") {
        it("handles base case") {
          check("\033[48;5;150mX") { result in
            expect(result).to(haveCount(1))
            expect(result[0]).to(have(background: 150))
            expect(result[0]).to(equal("X"))
          }
        }

        it("fails on to few args") {
          failing("\033[48;150mX")
        }
      }

      context("rgb color on the form ESC[48;2;r;g;bm") {
        it("handles base case") {
          check("\033[48;2;10;20;30mX") { result in
            expect(result).to(haveCount(1))
            expect(result[0]).to(have(background: [10, 20, 30]))
            expect(result[0]).to(equal("X"))
          }
        }

        it("fails on to few args") {
          failing("\033[48;2;10;20;mX")
        }
      }
    }
  }
}
