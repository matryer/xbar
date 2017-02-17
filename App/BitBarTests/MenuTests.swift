import Quick
import Nimble
@testable import BitBar

enum W<T> {
  case success(T)
  case failure
}

func the(_ menu: Menuable, at index: Int) -> W<Menuable> {
  return the(menu, at: [index])
}

func the(_ menu: Menuable, at indexes: [Int] = []) -> W<Menuable> {
  if indexes.isEmpty { return .success(menu) }
  if menu.menus.count <= indexes[0] { return .failure }
  return the(menu.menus[indexes[0]], at: Array(indexes[1..<indexes.count]))
}

func have(foreground color: CColor) -> MatcherFunc<W<Menuable>> {
  return tester("have a foreground") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.aTitle.has(foreground: color.toNSColor())
    case .failure:
      return "expected a color much like \(color)"
    }
  }
}

func toImage(string: String) -> NSImage? {
  let data = Data(
    base64Encoded: string,
    options: Data.Base64DecodingOptions(rawValue: 0)
  )

  if data == nil { preconditionFailure("Could not parse data") }
  return NSImage(data: data!)
}

func have(image: String, isTemplate: Bool) -> MatcherFunc<W<Menuable>> {
  return tester("have an image") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      guard let image1 = menu.image else {
        return "failed to parse image in menu"
      }

      guard let image2 = toImage(string: image) else {
        return "failed to parse image in menu"
      }

      // TODO: Compare content, not size
      guard image1.size == image2.size else {
        return false
      }

      if isTemplate {
        return image1.isTemplate
      }

      return !image1.isTemplate
    case .failure:
      return "to have an image"
    }
  }
}

func have(title: String) -> MatcherFunc<W<Menuable>> {
  return tester("have a title") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.aTitle.string == title
    case .failure:
      return "to have a title"
    }
  }
}

func have(title: Mutable) -> MatcherFunc<W<Menuable>> {
  return tester("have a title") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.aTitle == title
    case .failure:
      return "to have a title"
    }
  }
}

func have(font: String) -> MatcherFunc<W<Menuable>> {
  return tester("to have have font") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.aTitle.fontName == font
    case .failure:
      return "expected font \(font)"
    }
  }
}

func have(background color: CColor) -> MatcherFunc<W<Menuable>> {
  return tester("have a background") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.aTitle.has(background: color.toNSColor())
    case .failure:
      return "expected a color much like \(color)"
    }
  }
}

func have(size: Int) -> MatcherFunc<W<Menuable>> {
  return tester("to have size") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.aTitle.fontSize == size
    case .failure:
      return "expected a menu"
    }
  }
}

func beBold() -> MatcherFunc<W<Menuable>> {
  return tester("bold") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.aTitle.isBold
    case .failure:
      return "failed with a failure"
    }
  }
}

func beClickable() -> MatcherFunc<W<Menuable>> {
  return tester("clickable") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.isEnabled
    case .failure:
      return "failed with a failure"
    }
  }
}

func haveSubMenuCount(_ count: Int) -> MatcherFunc<W<Menuable>> {
  return tester("have sub menus") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.menus.count == count
    case .failure:
      return "failed to get menu"
    }
  }
}

func beAnAlternate() -> MatcherFunc<W<Menuable>> {
  return tester("alternate") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.isAltAlternate
    case .failure:
      return "failed with a failure"
    }
  }
}

func beChecked() -> MatcherFunc<W<Menuable>> {
  return tester("alternate") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.isChecked
    case .failure:
      return "failed with a failure"
    }
  }
}

func beItalic() -> MatcherFunc<W<Menuable>> {
  return tester("italic") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
      return menu.aTitle.isItalic
    case .failure:
      return "failed with a failure"
    }
  }
}

func beTrimmed() -> MatcherFunc<W<Menuable>> {
  return tester("trimmed") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
    return menu.aTitle == menu.aTitle.trimmed()
    case .failure:
      return "to be trimmed"
    }
  }
}

func have(href: String) -> MatcherFunc<W<Menuable>> {
  return tester("href") { (result: W<Menuable>) in
    switch result {
    case let .success(menu):
    return menu.aTitle == menu.aTitle.trimmed()
    case .failure:
      return "to be trimmed"
    }
  }
}

class MenuTests: Helper {
  override func spec() {
    let setup = { (_ input: String..., block: @escaping (Menuable) -> Void) in
      self.match(Pro.menu, input.joined() + "\n") { (menu, _) in
        block(menu)
      }
    }

    context("sub menu") {
      it("is active if it has sub menus") {
        setup("A\n--B\n") { menu in
          expect(the(menu)).to(beClickable())
          expect(the(menu, at: [0])).notTo(beClickable())
        }
      }

      it("is active if it has sub sub menus") {
        setup("A\n--B\n----C\n") { menu in
          expect(the(menu)).to(beClickable())
          expect(the(menu, at: [0])).to(beClickable())
          expect(the(menu, at: [0, 0])).notTo(beClickable())
        }
      }
    }

    context("ansi") {
      let title = "This is a title"
      it("should bold text") {
        setup(title.bold  + "|ansi=true\n") { menu in
          expect(the(menu)).to(beBold())
        }
      }

      it("should italic text") {
        setup(title.italic  + "|ansi=true\n") { menu in
          expect(the(menu)).to(beItalic())
        }
      }

      it("should not bold text") {
        setup(title.bold  + "|ansi=false\n") { menu in
          expect(the(menu)).notTo(beBold())
        }
      }

      context("foreground & background") {
        it("handles words consisting of both") {
          setup(title.background(color: .red).foreground(color: .blue) + "|ansi=true\n") { menu in
            expect(the(menu)).to(have(background: .red))
            expect(the(menu)).to(have(foreground: .blue))
          }
        }

        it("handles concatenated words") {
          let w1 = "A"
          let w2 = "B"
          let input = w1.background(color: .red) + w2.foreground(color: .blue)
          let output = w1.mutable().background(color: .red)
            + w2.mutable().foreground(color: .blue)
          setup(input + "|ansi=true\n") { menu in
            expect(the(menu)).to(have(title: output))
          }
        }

        it("handles concatenated words and mixed") {
          let w1 = "A"
          let w2 = "B"
          let input = w1.background(color: .red).foreground(color: .yellow) + w2.foreground(color: .blue)
          let output = w1.mutable().background(color: .red).foreground(color: .yellow)
            + w2.mutable().foreground(color: .blue)
          setup(input + "|ansi=true\n") { menu in
            expect(the(menu)).to(have(title: output))
          }
        }
      }

      context("foreground") {
        it("should have the color red") {
          setup(title + "|color=red\n") { menu in
            expect(the(menu)).to(have(foreground: .red))
          }
        }

        it("should have the color blue") {
          setup(title + "|color=blue\n") { menu in
            expect(the(menu)).to(have(foreground: .blue))
          }
        }

        it("should have no color") {
          setup(title  + "|color=xxx\n") { menu in
            expect(the(menu)).notTo(have(foreground: .blue))
          }
        }

        pending("displays error message if color doesnt exist") {}
        pending("handles mixed lower and uppercase") {}
      }

      context("bash") {
        it("is clickable when turned on") {
          setup(title + "|bash=/bin/sh") { menu in
            expect(the(menu)).to(beClickable())
          }
        }
      }

      context("image") {
        let image = "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"

        it("handles image") {
          setup("An image" + "|image=" + image) { menu in
            expect(the(menu)).to(have(image: image, isTemplate: false))
          }
        }

        it("handles template image") {
          setup("An image" + "|templateImage=" + image) { menu in
            expect(the(menu)).to(have(image: image, isTemplate: true))
          }
        }
      }

      context("href") {
        it("handles base case") {
          setup(title + "|href=http://google.com") { menu in
            expect(the(menu)).to(have(href: "http://google.com"))
            expect(the(menu)).to(beClickable())
          }
        }
      }

      context("clickable") {
        it("is not clickable by default") {
          setup(title) { menu in
            expect(the(menu)).toNot(beClickable())
          }
        }
      }

      context("terminal") {
        it("is clickable when turned on") {
          setup(title + "|terminal=true") { menu in
            expect(the(menu)).toNot(beClickable())
          }
        }

        it("is clickable when turned off") {
          setup(title + "|terminal=false") { menu in
            expect(the(menu)).toNot(beClickable())
          }
        }
      }

      context("dropdown") {
        it("should have no dropdown") {
          setup("A|dropdown=false\n--Sub menu\n") { menu in
            expect(menu.menus).to(beEmpty())
          }
        }

        it("should have dropdown") {
          setup("A|dropdown=true\n--Sub menu\n") { menu in
            expect(the(menu)).to(haveSubMenuCount(1))
          }
        }

        it("should default to sub menu") {
          setup("A\n--Sub menu\n") { menu in
            expect(the(menu)).to(haveSubMenuCount(1))
          }
        }
      }

      context("size") {
        it("handles size > 0") {
          setup(title + "|size=10") { menu in
            expect(the(menu)).to(have(size: 10))
          }
        }
      }

      context("alternate") {
        it("handles true value") {
          setup(title + "|alternate=true") { menu in
            expect(the(menu)).to(beAnAlternate())
          }
        }

        it("handles false value") {
          setup(title + "|alternate=false") { menu in
            expect(the(menu)).notTo(beAnAlternate())
          }
        }

        it("defaults to false") {
          setup(title) { menu in
            expect(the(menu)).notTo(beAnAlternate())
          }
        }
      }

      context("checked") {
        it("handles true value") {
          setup(title + "|checked=true") { menu in
            expect(the(menu)).to(beChecked())
          }
        }

        it("handles false value") {
          setup(title + "|alternate=false") { menu in
            expect(the(menu)).notTo(beChecked())
          }
        }

        it("defaults to false") {
          setup(title) { menu in
            expect(the(menu)).notTo(beChecked())
          }
        }
      }

      context("font") {
        it("handles font without space") {
          setup(title + "|font=Monaco") { menu in
            expect(the(menu)).to(have(font: "Monaco"))
          }
        }

        it("handles quotes font without space") {
          setup(title + "|font=\"Monaco\"") { menu in
            expect(the(menu)).to(have(font: "Monaco"))
          }
        }
      }

      context("emojize") {
        it("handles emojize (true)") {
          setup(":mushroom:|emojize=true") { menu in
            expect(the(menu)).to(have(title: "🍄"))
          }
        }

        it("handles emojize (false)") {
          setup(":mushroom:|emojize=false") { menu in
            expect(the(menu)).to(have(title: ":mushroom:"))
          }
        }

        it("handles invalid emojize") {
          setup(":mush:|emojize=true") { menu in
            expect(the(menu)).to(have(title: ":mush:"))
          }
        }
      }

      context("length") {
        it("handles length less then text") {
          setup("ABC|length=1") { menu in
            expect(the(menu)).to(have(title: "A…"))
          }
        }

        it("handles length greater then text") {
          setup("ABC|length=100") { menu in
            expect(the(menu)).to(have(title: "ABC"))
          }
        }
      }

      context("trim") {
        let title = "  A  "
        it("handles true base case") {
          setup(title + "|trim=true") { menu in
            expect(the(menu)).to(beTrimmed())
          }
        }

        it("handles false base case") {
          setup(title + "|trim=false") { menu in
            expect(the(menu)).notTo(beTrimmed())
          }
        }
      }

      context("background") {
        it("should have the color red") {
          setup(title.background(color: .red)  + "|ansi=true\n") { menu in
            expect(the(menu)).to(have(background: .red))
          }
        }

        it("should have the color blue") {
          setup(title.background(color: .blue)  + "|ansi=true\n") { menu in
            expect(the(menu)).to(have(background: .blue))
          }
        }

        it("should have no background") {
          setup(title.background(color: .blue)  + "|ansi=false\n") { menu in
            expect(the(menu)).notTo(have(background: .blue))
          }
        }
      }
    }

    let addSuffix = { return $0 + "\n" }
    context("params") {
      it("fails on | but no params") {
        self.failure(Pro.menu, addSuffix("My Menu|"))
      }
    }

    it("handles no input") {
      self.match(Pro.getMenu(), addSuffix("")) {
        expect($0.getValue()).to(equal(""))
        expect($0.menus).to(haveCount(0))
        expect($1).to(beEmpty())
      }
    }

    it("handles escaped input") {
      self.match(Pro.getMenu(), addSuffix("A B C\\|")) {
        expect($0.getValue()).to(equal("A B C|"))
        expect($0.menus).to(haveCount(0))
        expect($1).to(beEmpty())
      }
    }

    context("sub menu") {
      it("has one sub") {
        self.match(Pro.getMenu(), addSuffix("My Menu\n--A")) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($0.menus).to(haveCount(1))
          expect($0.menus[0].getValue()).to(equal("A"))
          expect($1).to(beEmpty())
        }
      }

      it("has +1 subs") {
        self.match(Pro.getMenu(), addSuffix("My Menu\n--A\n--B")) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($0.menus).to(haveCount(2))
          expect($0.menus[0].getValue()).to(equal("A"))
          expect($0.menus[1].getValue()).to(equal("B"))
          expect($1).to(beEmpty())
        }
      }

      it("has menu with params and +1 subs") {
        self.match(Pro.getMenu(), addSuffix("My Menu| size=10\n--A\n--B")) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($0.menus).to(haveCount(2))
          expect($0.menus[0].getValue()).to(equal("A"))
          expect($0.menus[1].getValue()).to(equal("B"))
          expect($1).to(beEmpty())
        }
      }

      it("has subs with params") {
        self.match(Pro.getMenu(), addSuffix("My Menu\n--A| font=Monaco \n--B")) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($0.menus).to(haveCount(2))
          let sub = $0.menus[0]
          expect(sub.getValue()).to(equal("A"))
          expect($0.menus[1].getValue()).to(equal("B"))
          expect($1).to(beEmpty())
        }
      }
    }

    context("no sub menu") {
      it("handles base case") {
        self.match(Pro.getMenu(), addSuffix("My Menu")) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($1).to(beEmpty())
        }
      }

      it("handles no input") {
        self.match(Pro.getMenu(), addSuffix("")) {
          expect($0.getValue()).to(equal(""))
          expect($1).to(beEmpty())
        }
      }
    }

    context("params") {
      it("consumes spaces") {
        let arg = addSuffix("My Menu| terminal=true ")
        self.match(Pro.menu, arg) {
          expect($0.getValue()).to(equal("My Menu"))
          expect($1).to(beEmpty())
        }
      }

      it("handles stream") {
        let arg = addSuffix("My Menu| terminal=true")
        self.match(Pro.getMenu(), arg) {
          expect($0.getValue()).to(equal("My Menu"))
        }
      }

      context("terminal") {
        it("it handles true") {
          let arg = addSuffix("My Menu|terminal=true")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(beEmpty())
          }
        }

        it("it handles false") {
          let arg = addSuffix("My Menu|terminal=false")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(beEmpty())
          }
        }

        it("it handles space between menu and param") {
          let arg = addSuffix("My Menu | terminal=false")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(beEmpty())
          }
        }
      }

      context("trim") {
        it("it handles true") {
          let arg = addSuffix("My Menu|terminal=true trim=true")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu"))
            expect($1).to(beEmpty())
          }
        }

        it("it handles false") {
          let arg = addSuffix("My Menu |terminal=false trim=false")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu "))
            expect($1).to(beEmpty())
          }
        }

        it("it handles space between menu and param") {
          let arg = addSuffix("My Menu | terminal=false trim=false")
          self.match(Pro.getMenu(), arg) {
            expect($0.getValue()).to(equal("My Menu "))
            expect($1).to(beEmpty())
          }
        }
      }
    }

    context("merge") {
      it("merges title") {
        let menu1 = Menu("X")
        let menu2 = Menu("Y")

        expect(menu1.equals(menu2)).to(beFalse())
        menu1.merge(with: menu2)
        expect(menu1.equals(menu2)).to(beTrue())
        expect(menu2.equals(menu2)).to(beTrue())
      }

      it("merges sub menus") {
        let menu1 = Menu("M1")
        let menu2 = Menu("M2")
        let title1 = Menu("T1", menus: [menu1])
        let title2 = Menu("T2", menus: [menu2])

        title1.merge(with: title2)

        expect(title1.menus).to(haveCount(1))
        expect(title2.menus).to(haveCount(1))

        expect(title1.menus[0].equals(title2.menus[0])).to(beTrue())
      }
    }
  }
}
