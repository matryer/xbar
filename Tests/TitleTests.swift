// swiftlint:disable force_cast

import Quick
import Nimble
import Attr
@testable import BitBar

class TitleTests: Helper {
  override func spec() {
    let setup = { (_ input: String..., block: @escaping (Menuable) -> Void) in
      self.match(Pro.title, input.joined() + "\n", block)
    }

    context("matching") {
      context("no params") {
        it("handles simple string") {
          self.match(Pro.flat, "ABC\n") { (data: R) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(0))
          }
        }

        it("handles string with newline") {
          self.match(Pro.flat, "ABC\n") { (data: R) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(0))
          }
        }

        it("handles empty string") {
          self.match(Pro.flat, "\n") { (data: R) in
            expect(data.0).to(equal(""))
            expect(data.1).to(haveCount(0))
          }
        }

        it("handles only newline") {
          self.match(Pro.flat, "\n") { (data: R) in
            expect(data.0).to(equal(""))
            expect(data.1).to(haveCount(0))
          }
        }
      }

      context("sub menu") {
        it("is active if it has sub menus") {
          setup("A\n---\nB\n") { menu in
            expect(the(menu)).to(beClickable())
            expect(the(menu, at: [0])).notTo(beClickable())
          }
        }

        it("is active if it has sub sub menus") {
          setup("A\n---\nB\n--C\n") { menu in
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

          it("should fail if color doesn't exist") {
            self.failure(Pro.title, title  + "|color=xxx\n")
          }

          pending("handles mixed lower and uppercase") {}
        }
      }

      context("params") {
        let terminal = Terminal(true)
        it("handles simple string") {
          self.match(Pro.flat, "ABC|terminal=true\n") { (data: R) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
          }
        }

        it("handles string with newline") {
          self.match(Pro.flat, "ABC|terminal=true\n") { (data: R) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
          }
        }

        it("handles empty string") {
          self.match(Pro.flat, "|terminal=true\n") { (data: R) in
            expect(data.0).to(equal(""))
            expect(data.1).to(haveCount(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
          }
        }
      }

      context("withPrefix") {
        let terminal = Terminal(true)
        it("handles no prefix") {
          self.match(Pro.headingFor(level: 0), "ABC\n") { (data: X) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(0))
            expect(data.2).to(equal(0))
          }
        }

        it("handles no prefix with param") {
          self.match(Pro.headingFor(level: 0), "ABC|terminal=true\n") { (data: X) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(1))
            expect(data.2).to(equal(0))
            expect(data.1[0].equals(terminal)).to(beTrue())
          }
        }

        it("handles one level") {
          self.match(Pro.headingFor(level: 1), "--ABC\n") { (data: X) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(0))
            expect(data.2).to(equal(1))
          }
        }

        it("handles no prefix with param") {
          self.match(Pro.headingFor(level: 1), "--ABC|terminal=true\n") { (data: X) in
            expect(data.0).to(equal("ABC"))
            expect(data.1).to(haveCount(1))
            expect(data.2).to(equal(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
          }
        }

        it("handles prefix with prefix inline") {
          self.match(Pro.headingFor(level: 1), "--ABC--|terminal=true\n") { (data: X) in
            expect(data.0).to(equal("ABC--"))
            expect(data.1).to(haveCount(1))
            expect(data.2).to(equal(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
          }
        }

        it("handles two levels") {
          self.match(Pro.headingFor(level: 2), "----ABC-X-Y\n") { (data: X) in
            expect(data.0).to(equal("ABC-X-Y"))
            expect(data.2).to(equal(2))
            expect(data.1).to(haveCount(0))
          }
        }

        it("handles level with no input") {
          self.match(Pro.headingFor(level: 2), "----\n") { (data: X) in
            expect(data.0).to(equal(""))
            expect(data.2).to(equal(2))
            expect(data.1).to(haveCount(0))
          }
        }

        it("with newline") {
          self.match(Pro.headingFor(level: 1), "--\n") { (data: X) in
            expect(data.0).to(equal(""))
            expect(data.1).to(haveCount(0))
            expect(data.2).to(equal(1))
          }
        }

        it("with params") {
          self.match(Pro.headingFor(level: 1), "--|terminal=true\n") { (data: X) in
            expect(data.0).to(equal(""))
            expect(data.2).to(equal(1))
            expect(data.1).to(haveCount(1))
            expect(data.1[0].equals(terminal)).to(beTrue())
          }
        }

        context("moreOver") {
          it("handles basic example") {
            self.match(Pro.headings, "\n--|terminal=true\n") { (data: [X]) in
              expect(data).to(haveCount(2))
            }
          }

          it("handles more then one") {
            self.match(Pro.headings, "\n--|terminal=true\n--|terminal=false\n") { (data: [X]) in
              expect(data).to(haveCount(3))
            }
          }

          it("empty string") {
            self.match(Pro.headings, "\n") { (data: [X]) in
              expect(data).to(haveCount(1))
            }
          }

          it("handles just newlines") {
            self.match(Pro.headings, "\n\n\n") { (data: [X]) in
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
            self.match(Pro.headings, basic) { (data: [X]) in
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
        expect($0.headline.string).to(equal("A"))
        expect($0.menus).to(haveCount(2))
        expect($0.menus[0].headline.string).to(equal("B"))
        expect($0.menus[1].headline.string).to(equal("D"))
      }
    }

    it("no longer failes") {
      let input = "A\n---\nB\nD\n"
      self.match(Pro.title, input) {
        expect($0.headline.string).to(equal("A"))
        expect($0.menus[0].headline.string).to(equal("B"))
        expect($0.menus).to(haveCount(2))
      }
    }

    context("no menu") {
      it("handles base case") {
        self.match(Pro.title, "My Title\n") {
          expect($0.headline.string).to(equal("My Title"))
        }
      }

      it("handles new line") {
        self.match(Pro.title, "\n") {
          expect($0.headline.string).to(beEmpty())
        }
      }
    }

    context("with menu") {
      it("handles base case") {
        self.match(Pro.title, "My Title\n---\n") { (title: Title) in
          expect(title.headline.string).to(equal("My Title"))
          expect(title.menus).to(haveCount(0))
        }
      }

      it("handles nested menus") {
        let arg = "My Title\n---\nA\n--B\n----C\n"
        self.match(Pro.title, arg) { (title: Title) in
          expect(title.headline.string).to(equal("My Title"))
          expect(title.menus).to(haveCount(1))
          expect(title.menus[0].headline.string).to(equal("A"))
          expect(title.menus[0].menus[0].headline.string).to(equal("B"))
          expect(title.menus[0].menus[0].menus[0].headline.string).to(equal("C"))
        }
      }
    }

    context("no ---") {
      it("handles with params") {
        self.match(Pro.getTitle(), "A\n---\nB|terminal=false\nC|terminal=false\n") {
          expect($0.headline.string).to(equal("A"))
          expect($0.menus).to(haveCount(2))
          expect($0.menus[0].headline.string).to(equal("B"))
          expect($0.menus[1].headline.string).to(equal("C"))
          expect($0.menus[0].openInTerminal).to(beFalse())
          expect($0.menus[1].openInTerminal).to(beFalse())
        }
      }

      it("handles just one menu") {
        self.match(Pro.getTitle(), "A\n---\nB|terminal=false\n") {
          expect($0.headline.string).to(equal("A"))
          expect($0.menus).to(haveCount(1))
          expect($0.menus[0].headline.string).to(equal("B"))
          expect($0.menus[0].openInTerminal).to(beFalse())
        }
      }

      it("handles empty menu") {
        self.match(Pro.getTitle(), "A\n---\n") {
          expect($0.headline.string).to(equal("A"))
          expect($0.menus).to(haveCount(0))
        }
      }

      it("handles sub") {
        self.match(Pro.getTitle(), "A\n---\nB\n--C\nD\n") {
          expect($0.headline.string).to(equal("A"))
          expect($0.menus).to(haveCount(2))
          expect($0.menus[0].menus).to(haveCount(1))
          expect($0.menus[0].headline.string).to(equal("B"))
          expect($0.menus[1].headline.string).to(equal("D"))
          expect($0.menus[0].menus[0].headline.string).to(equal("C"))
        }
      }
    }
  }
}
