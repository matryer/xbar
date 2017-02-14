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

class MenuTests: Helper {
  override func spec() {
    let setup = { (_ input: String, block: @escaping (Menuable) -> Void) in
      self.match(Pro.menu, input) { (menu, _) in
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
        self.match(Pro.getMenu(), addSuffix("My Menu\n--A| font=X \n--B")) {
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
