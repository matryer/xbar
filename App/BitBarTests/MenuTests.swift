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

// func respond(toScript script: String) -> MatcherFunc<W<Menuable>> {
//   return tester("to script") { (result: W<Menuable>) in
//     switch result {
//     case let .success(menu):
//       return menu.aTitle.has(background: color.toNSColor())
//     case .failure:
//       return "expected a color much like \(color)"
//     }
//   }
// }

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

class MenuTests: Helper {
  override func spec() {
    let setup = { (_ input: String..., block: @escaping (Menuable) -> Void) in
      self.match(Pro.menu, input.joined() + "\n") { (menu, _) in
        block(menu)
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
          print("warning:", input.replace("\0", "X"))
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
      }

      // context("bash") {
      //   it("should be clickable") {
      //     setup(title, "|bash=\"/bin/sh\"") { menu in
      //       expect(the(menu)).to(respond(toScript: "/bin/sh"))
      //     }
      //   }
      // }

      context("size") {
        it("handles size > 0") {
          setup(title + "|size=10") { menu in
            expect(the(menu)).to(have(size: 10))
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
        self.match(Pro.getMenu(), arg) {
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
