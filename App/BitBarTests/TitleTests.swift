import Quick
import Nimble
@testable import BitBar

typealias R = (String, [Param])
class TitleTests: Helper {
  override func spec() {

    context("matching") {
      context("no params") {
        it("handles simple string") {
          self.match(Pro.flat, "ABC\n") { (data: R, rem: String) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(0))
            expect(rem).to(beEmpty())
          }
        }

        it("handles string with newline") {
          self.match(Pro.flat, "ABC\n") { (data: R, rem: String) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(0))
            expect(rem).to(beEmpty())
          }
        }

        it("handles empty string") {
          self.match(Pro.flat, "\n") { (data: R, rem: String) in
            expect(data.0).to(equal(""))
            expect(data.1).to(haveCount(0))
            expect(rem).to(beEmpty())
          }
        }

        it("handles only newline") {
          self.match(Pro.flat, "\n") { (data: R, rem: String) in
            expect(data.0).to(equal(""))
            expect(data.1).to(haveCount(0))
            expect(rem).to(beEmpty())
          }
        }
      }

      context("params") {
        let terminal = Terminal(true)
        it("handles simple string") {
          self.match(Pro.flat, "ABC|terminal=true\n") { (data: R, rem: String) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
            expect(rem).to(beEmpty())
          }
        }

        it("handles string with newline") {
          self.match(Pro.flat, "ABC|terminal=true\n") { (data: R, rem: String) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
            expect(rem).to(beEmpty())
          }
        }

        it("handles empty string") {
          self.match(Pro.flat, "|terminal=true\n") { (data: R, rem: String) in
            expect(data.0).to(equal(""))
            expect(data.1).to(haveCount(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
            expect(rem).to(beEmpty())
          }
        }
      }

      context("withPrefix") {
        let terminal = Terminal(true)
        it("handles no prefix") {
          self.match(Pro.headingFor(level: 0), "ABC\n") { (data: X, rem: String) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(0))
            expect(data.2).to(equal(0))
            expect(rem).to(beEmpty())
          }
        }

        it("handles no prefix with param") {
          self.match(Pro.headingFor(level: 0), "ABC|terminal=true\n") { (data: X, rem: String) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(1))
            expect(data.2).to(equal(0))
            expect(data.1[0].equals(terminal)).to(beTrue())
            expect(rem).to(beEmpty())
          }
        }

        it("handles one level") {
          self.match(Pro.headingFor(level: 1), "--ABC\n") { (data: X, rem: String) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(0))
            expect(data.2).to(equal(1))
            expect(rem).to(beEmpty())
          }
        }

        it("handles no prefix with param") {
          self.match(Pro.headingFor(level: 1), "--ABC|terminal=true\n") { (data: X, rem: String) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(1))
            expect(data.2).to(equal(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
            expect(rem).to(beEmpty())
          }
        }

        it("handles prefix with prefix inline") {
          self.match(Pro.headingFor(level: 1), "--ABC--|terminal=true\n") { (data: X, rem: String) in
            expect(data.0).to(equal("ABC--"))
            expect(data.1).to(haveCount(1))
            expect(data.2).to(equal(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
            expect(rem).to(beEmpty())
          }
        }

        it("handles two levels") {
          self.match(Pro.headingFor(level: 2), "----ABC-X-Y\n") { (data: X, rem: String) in
            expect(data.0).to(equal("ABC-X-Y"))
            expect(data.2).to(equal(2))
            expect(data.1).to(haveCount(0))
            expect(rem).to(beEmpty())
          }
        }

        it("handles level with no input") {
          self.match(Pro.headingFor(level: 2), "----\n") { (data: X, rem: String) in
            expect(data.0).to(equal(""))
            expect(data.2).to(equal(2))
            expect(data.1).to(haveCount(0))
            expect(rem).to(beEmpty())
          }
        }

        it("handles uneven --") {
          self.match(Pro.headingFor(level: 1), "---\n") { (data: X, rem: String) in
            expect(data.0).to(equal("-"))
            expect(data.2).to(equal(1))
            expect(data.1).to(haveCount(0))
            expect(rem).to(beEmpty())
          }
        }

        it("with newline") {
          self.match(Pro.headingFor(level: 1), "--\n") { (data: X, rem: String) in
            expect(data.0).to(equal(""))
            expect(data.1).to(haveCount(0))
            expect(data.2).to(equal(1))
            expect(rem).to(beEmpty())
          }
        }

        it("with params") {
          self.match(Pro.headingFor(level: 1), "--|terminal=true\n") { (data: X, rem: String) in
            expect(data.0).to(equal(""))
            expect(data.2).to(equal(1))
            expect(data.1).to(haveCount(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
            expect(rem).to(beEmpty())
          }
        }

        context("moreOver") {
          it("handles basic example") {
            self.match(Pro.headings, "\n--|terminal=true\n") { (data: [X], _) in
              expect(data).to(haveCount(2))
            }
          }

          it("handles more then one") {
            self.match(Pro.headings, "\n--|terminal=true\n--|terminal=false\n") { (data: [X], _) in
              expect(data).to(haveCount(3))
            }
          }

          it("empty string") {
            self.match(Pro.headings, "\n") { (data: [X], _) in
              expect(data).to(haveCount(1))
            }
          }

          it("handles just newlines") {
            self.match(Pro.headings, "\n\n\n") { (data: [X], _) in
              expect(data.count).to(equal(1))
            }
          }

          it("handles steps") {
            var basic = "A|size=10"
            basic += "\n--B|size=20"
            basic += "\n----C|size=5"
            basic += "\n--D|size=10"
            basic += "\n--E|size=19"
            basic += "\nF|size=1\n"
            self.match(Pro.headings, basic) { (data: [X], _) in
              expect(data.count).to(equal(6))
//              let empty = [Param]()
              let matching = [("A", 0, 10), ("B", 1, 20), ("C", 2, 5), ("D", 1, 10), ("E", 1, 19), ("F", 0, 1)]

              for (index, item) in matching.enumerated() {
                expect(item.0).to(equal(data[index].0))
                expect(item.1).to(equal(data[index].2))

                let params = data[index].1
                let size = params[0] as! Size
                expect(params).to(haveCount(1))
                expect((size).equals(Size(item.2))).to(beTrue())
              }
            }
          }
        }
      }
    }

    it("handles nested menu") {
      let input = "A\n---\nB\n--C\nD\n"
      self.match(Pro.title, input) {
        expect($0.getValue()).to(equal("A"))
        expect($0.menus).to(haveCount(2))
        expect($0.menus[0].getValue()).to(equal("B"))
        expect($0.menus[1].getValue()).to(equal("D"))
        expect($1).to(beEmpty())
      }
    }

    it("no longer failes") {
      let input = "A\n---\nB\nD\n"
      self.match(Pro.title, input) {
        expect($0.getValue()).to(equal("A"))
        expect($0.menus[0].getValue()).to(equal("B"))
        expect($0.menus).to(haveCount(2))
        expect($1).to(beEmpty())
      }
    }

    context("no menu") {
      it("handles base case") {
        self.match(Pro.title, "My Title\n") {
          expect($0.getValue()).to(equal("My Title"))
          expect($1).to(beEmpty())
        }
      }

      it("handles new line") {
        self.match(Pro.title, "\n") {
          expect($0.getValue()).to(beEmpty())
//          expect($1).to(beEmpty())
        }
      }
    }

    context("with menu") {
      it("handles base case") {
        self.match(Pro.title, "My Title\n---\n") { (title: Title, rem: String) in
          expect(title.getValue()).to(equal("My Title"))
          expect(title.menus).to(haveCount(0))
          expect(rem).to(beEmpty())
        }
      }

      it("handles nested menus") {
        let arg = "My Title\n---\nA\n--B\n----C\n"
        self.match(Pro.getTitle(), arg) { (title: Title, _) in
          expect(title.getValue()).to(equal("My Title"))
          expect(title.menus).to(haveCount(1))
          expect(title.menus[0].getValue()).to(equal("A"))
          expect(title.menus[0].menus[0].getValue()).to(equal("B"))
          expect(title.menus[0].menus[0].menus[0].getValue()).to(equal("C"))
        }
      }
    }

    context("merge") {
      it("merges title") {
        let title1 = Title("X")
        let title2 = Title("Y")

        title1.merge(with: title2)
        expect(title1.equals(title2)).to(beTrue())
        expect(title2.equals(title2)).to(beTrue())
      }

      it("merges menus") {
        let menu1 = Menu("M1")
        let menu2 = Menu("M2")
        let title1 = Title("T1", menus: [menu1])
        let title2 = Title("T2", menus: [menu2])

        title1.merge(with: title2)

        expect(title1.menus).to(haveCount(1))
        expect(title2.menus).to(haveCount(1))

        expect(title1.menus[0].equals(title2.menus[0])).to(beTrue())
      }
    }

    context("no ---") {
      it("handles with params") {
        self.match(Pro.getTitle(), "A\n---\nB|terminal=false\nC|terminal=false\n") {
          expect($0.getValue()).to(equal("A"))
          expect($0.menus).to(haveCount(2))
          expect($0.menus[0].getTitle()).to(equal("B"))
          expect($0.menus[1].getTitle()).to(equal("C"))
          expect($0.menus[0].openTerminal()).to(beFalse())
          expect($0.menus[1].openTerminal()).to(beFalse())
          expect($1).to(beEmpty())
        }
      }

      it("handles just one menu") {
        self.match(Pro.getTitle(), "A\n---\nB|terminal=false\n") {
          expect($0.getValue()).to(equal("A"))
          expect($0.menus).to(haveCount(1))
          expect($0.menus[0].getTitle()).to(equal("B"))
          expect($0.menus[0].openTerminal()).to(beFalse())
          expect($1).to(beEmpty())
        }
      }

      it("handles empty menu") {
        self.match(Pro.getTitle(), "A\n---\n") {
          expect($0.getValue()).to(equal("A"))
          expect($0.menus).to(haveCount(0))
          expect($1).to(beEmpty())
        }
      }

      it("handles sub") {
        self.match(Pro.getTitle(), "A\n---\nB\n--C\nD\n") {
          expect($0.getValue()).to(equal("A"))
          expect($0.menus).to(haveCount(2))
          expect($0.menus[0].menus).to(haveCount(1))
          expect($0.menus[0].getTitle()).to(equal("B"))
          expect($0.menus[1].getTitle()).to(equal("D"))
          expect($0.menus[0].menus[0].getTitle()).to(equal("C"))
          expect($1).to(beEmpty())
        }
      }
    }
  }
}
