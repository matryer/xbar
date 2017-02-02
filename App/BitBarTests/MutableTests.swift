import Quick
import Nimble
import Hue
@testable import BitBar

public func beBold() -> MatcherFunc<Mutable> {
  return MatcherFunc { actual, _ in
    guard let mutable = try actual.evaluate() else {
      return false
    }

    return mutable.isBold
  }
}

public func haveAForeground() -> MatcherFunc<Mutable> {
  return MatcherFunc { actual, _ in
    guard let mutable = try actual.evaluate() else {
      return false
    }

    return mutable.has(.foreground)
  }
}

public func haveABackground() -> MatcherFunc<Mutable> {
  return MatcherFunc { actual, _ in
    guard let mutable = try actual.evaluate() else {
      return false
    }

    return mutable.has(.background)
  }
}

public func have(background color: NSColor) -> MatcherFunc<Mutable> {
  return MatcherFunc { actual, _ in
    guard let mutable = try actual.evaluate() else {
      return false
    }

    return mutable.has(background: color)
  }
}

public func have(fontSize: Int) -> MatcherFunc<Mutable> {
  return tester("font size") { mutable in
    return mutable.fontSize == fontSize
  }
}

public func have(fontName: String) -> MatcherFunc<Mutable> {
  return tester("font name") { mutable in
    return mutable.fontName == fontName
  }
}

public func have(foreground color: NSColor) -> MatcherFunc<Mutable> {
  return MatcherFunc { actual, _ in
    guard let mutable = try actual.evaluate() else {
      return false
    }

    return mutable.has(foreground: color)
  }
}

public func beItalic() -> MatcherFunc<Mutable> {
  return MatcherFunc { actual, _ in
    guard let mutable = try actual.evaluate() else {
      return false
    }
    return mutable.isItalic
  }
}

public func beStrikeThrough() -> MatcherFunc<Mutable> {
  return MatcherFunc { actual, _ in
    guard let mutable = try actual.evaluate() else {
      return false
    }

    return mutable.isStrikeThrough
  }
}

public func beUnderlined() -> MatcherFunc<Mutable> {
  return MatcherFunc { actual, _ in
    guard let mutable = try actual.evaluate() else {
      return false
    }

    return mutable.hasUnderline
  }
}

public func equal(_ expect: String) -> MatcherFunc<Mutable> {
  return MatcherFunc { actual, failure in

    failure.postfixMessage = "equal \(expect)"

    guard let mutable = try actual.evaluate() else {
      return false
    }

    if mutable.string == expect {
      return true
    }

    failure.postfixActual = mutable.string
    return false
  }
}

class MutableTests: Helper {
  override func spec() {
    var mutable: Mutable!

    beforeEach {
      mutable = Mutable(string: "ABC")
    }

    describe("bold") {
      it("is not bold by default") {
        expect(mutable).notTo(beBold())
      }

      it("can be bold") {
        expect(mutable.style(with: .bold)).to(beBold())
      }
    }

    describe("trimmed") {
      context("space") {
        it("removes pending whitespace") {
          expect(Mutable(string: "ABC  ").trimmed()).to(equal("ABC"))
        }

        it("removes prefixed whitespace") {
          expect(Mutable(string: "  ABC").trimmed()).to(equal("ABC"))
        }

        it("removes surrounding whitespace") {
          expect(Mutable(string: "  ABC   ").trimmed()).to(equal("ABC"))
        }
      }

      context("newline") {
        it("removes pending newline") {
          expect(Mutable(string: "ABC\n").trimmed()).to(equal("ABC"))
        }

        it("removes prefixed newline") {
          expect(Mutable(string: "\nABC").trimmed()).to(equal("ABC"))
        }

        it("removes surrounding newline") {
          expect(Mutable(string: "\nABC\n").trimmed()).to(equal("ABC"))
        }
      }

      context("combine") {
        it("doesn't alter existing style") {
          let mutable = Mutable(string: "  ABC   ")
          let trimmed = mutable.style(with: .bold).trimmed()
          expect(trimmed).to(beBold())
          expect(trimmed).to(equal("ABC"))
        }

        it("doesn't alter existing colors") {
          let mutable = Mutable(string: "  ABC   ")
          let color = NSColor(hex: "#ff00ff")
          let trimmed = mutable.style(with: .foreground(color)).trimmed()
          expect(trimmed).to(have(foreground: color))
          expect(trimmed).to(equal("ABC"))
        }
      }
    }

    context("font") {
      var mutable: Mutable!

      beforeEach {
        mutable = Mutable(string: "X")
      }

      it("handles empty string (fontName)") {
        expect(Mutable(string: "").update(fontName: "Monaco").fontName).notTo(equal( "Monaco"))
      }

      it("handles empty string (fontSize)") {
        let mutable = Mutable(string: "")
        let initSize = mutable.fontSize
        expect(Mutable(string: "").update(fontSize: 5)).to(have(fontSize: initSize))
      }

      it("updates the font name") {
        expect(mutable).notTo(have(fontName: "Monaco"))
        expect(mutable.update(fontName: "Monaco")).to(have(fontName: "Monaco"))
      }

      it("ignores invalid values") {
        expect(mutable.update(fontName: "X")).notTo(have(fontName: "C"))
      }

      it("ignores invalid size") {
        expect(mutable.update(fontSize: -1)).notTo(have(fontSize: -1))
      }

      it("updates the font size") {
        expect(mutable).notTo(have(fontSize: 25))
        expect(mutable.update(fontSize: 25)).to(have(fontSize: 25))
      }
    }

    describe("italic") {
      it("is not italic by default") {
        expect(mutable).notTo(beItalic())
      }

      it("can be italic") {
        expect(mutable.style(with: .italic)).to(beItalic())
      }
    }

    describe("strikethrough") {
      it("is not strikethrough by default") {
        expect(mutable).notTo(beStrikeThrough())
      }

      it("can be strikethrough") {
        expect(mutable.style(with: .strikethrough)).to(beStrikeThrough())
      }
    }

    describe("underline") {
      it("is not underlined by default") {
        expect(mutable).notTo(beUnderlined())
      }

      it("can be underlined") {
        expect(mutable.style(with: .underline)).to(beUnderlined())
      }
    }

    context("color") {
      var color: NSColor!

      beforeEach {
        color = NSColor(hex: "#000000")
      }

      describe("foreground") {
        it("is does not have a foreground default") {
          expect(mutable).notTo(haveAForeground())
        }

        it("it possible to add a foreground") {
          expect(mutable.style(with: .foreground(color))).to(have(foreground: color))
          expect(mutable).to(haveAForeground())
        }

        it("overrides the last value") {
          let color1 = NSColor(hex: "#000000")
          let color2 = NSColor(hex: "#ffffff")
          let another = mutable
            .style(with: .foreground(color1))
            .style(with: .foreground(color2))

          expect(another).to(have(foreground: color2))
          expect(another).notTo(have(foreground: color1))
        }
      }

      describe("background") {
        it("is does not have a background default") {
          expect(mutable).notTo(haveABackground())
        }

        it("it possible to add a background") {
          expect(mutable.style(with: .background(color))).to(have(background: color))
          expect(mutable).to(haveABackground())
        }

        it("overrides the last value") {
          let color1 = NSColor(hex: "#000000")
          let color2 = NSColor(hex: "#ffffff")
          let another = mutable
            .style(with: .background(color1))
            .style(with: .background(color2))

          expect(another).to(have(background: color2))
          expect(another).notTo(have(background: color1))
        }
      }

      context("combine") {
        it("can have both foreground and background") {
          let bColor = NSColor(hex: "#000000")
          let fColor = NSColor(hex: "#ffffff")
          let another = mutable
            .style(with: .background(bColor))
            .style(with: .foreground(fColor))

          expect(another).to(have(background: bColor))
          expect(another).to(have(foreground: fColor))
        }
      }
    }

    context("truncate") {
      it("truncates if value is to long") {
        expect(Mutable(string: "ABC").truncate(1)).to(equal("A…"))
      }

      it("does not truncate if the string is shorter then the provided length") {
        expect(Mutable(string: "ABC").truncate(10)).to(equal("ABC"))
      }

      it("does not truncate empty strings") {
        expect(Mutable(string: "").truncate(10)).to(equal(""))
      }

      it("is possible to set a custom suffix") {
        expect(Mutable(string: "ABC").truncate(1, suffix: "X")).to(equal("AX"))
      }

      it("does not alter the font") {
        let value = Mutable(string: "ABC")
        let font = value.font
        let newValue = value.truncate(1)
        expect(newValue.font).to(equal(font))
      }

      context("combine") {
        it("does not remove existing colors") {
          let color1 = NSColor(hex: "#ff00ff")
          let color2 = NSColor(hex: "#00ff00")
          let value = Mutable(string: "ABC")
          let newValue = value.style(with: .foreground(color1)).style(with: .background(color2)).truncate(1)
          expect(newValue).to(equal("A…"))
          expect(newValue).to(have(foreground: color1))
          expect(newValue).to(have(background: color2))
        }

        it("is possible to add more colors") {
          let color = NSColor(hex: "#00ff00")
          let value = Mutable(string: "ABC")
          let newValue = value.truncate(1).style(with: .background(color))
          expect(newValue).to(equal("A…"))
          expect(newValue).to(have(background: color))
        }
      }
    }

    context("combine") {
      var color: NSColor!

      beforeEach {
        color = NSColor(hex: "#000000")
      }

      it("can combine italic with bold and color") {
        let another = mutable.style(with: .italic).style(with: .bold).style(with: .background(color))
        expect(another).to(beItalic())
        expect(another).to(beBold())
        expect(another).to(have(background: color))
      }

      it("can combine underline with bold and color") {
        let another = mutable.style(with: .underline).style(with: .bold).style(with: .foreground(color))
        expect(another).to(beBold())
        expect(another).to(beUnderlined())
        expect(another).to(have(foreground: color))
      }

      it("can combine strikethrough with underline") {
        let another = mutable.style(with: .underline).style(with: .strikethrough).style(with: .background(color))
        expect(another).to(beStrikeThrough())
        expect(another).to(beUnderlined())
        expect(another).to(have(background: color))
      }

      it("can combine strikethrough with underline") {
        let another = mutable.style(with: .underline).style(with: .strikethrough).style(with: .foreground(color))
        expect(another).to(beStrikeThrough())
        expect(another).to(beUnderlined())
        expect(another).to(have(foreground: color))
      }
    }
  }
}
