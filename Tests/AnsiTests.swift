import Quick
import Nimble
import Attr
@testable import BitBar

class AnsiTests: Helper {
  override func spec() {
    let check = { (_ input: String, block: @escaping ([Value]) -> Void) in
      self.test(Pro.getANSIs(), input, block)
    }

    let failing = { (input: String) in
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

      it("handles two resets in a row") {
        let reset = "\033[0m"
        check("A" + reset + reset) { result in
          expect(result).to(haveCount(1))
          expect(result[0]).to(equal("A"))
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
