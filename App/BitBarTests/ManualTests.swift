import Quick
import Nimble
@testable import BitBar

class ManualTests: Helper {
  override func spec() {
    describe("parser") {
      describe("output") {
        context("stream") {
          it("no space between params") {
            self.match(Pro.getOutput(), "A\n---\nB|trim=true\n~~~") {
              expect($0.isStream).to(beTrue())
              expect($1).to(beEmpty())
            }
          }

          it("has title") {
            self.match(Pro.getOutput(), "A Title\n~~~") {
              expect($0.isStream).to(beTrue())
              expect($0.title.getValue()).to(equal("A Title"))
              expect($1).to(beEmpty())
            }
          }
        }

        context("no stream") {
          it("handles base case") {
            self.match(Pro.getOutput(), "") {
              expect($0.isStream).to(beFalse())
              expect($1).to(beEmpty())
            }
          }

          it("has title") {
            self.match(Pro.getOutput(), "A Title\n") {
              expect($0.isStream).to(beFalse())
              expect($0.title.getValue()).to(equal("A Title\n"))
              expect($1).to(beEmpty())
            }

            self.match(Pro.getOutput(), "A Title") {
              expect($0.isStream).to(beFalse())
              expect($0.title.getValue()).to(equal("A Title"))
              expect($1).to(beEmpty())
            }
          }
        }
      }

      describe("title") {
        it("menu") {
          let input = "S0 YM 2DR \n---\nL\n--i\n---\nC"
          self.match(Pro.getTitle(), input) {
            expect($0.getValue()).to(equal("S0 YM 2DR "))
            expect($0.menus).to(haveCount(2))
            expect($1).to(beEmpty())
          }
        }

        it("no longer failes") {
          let input = "A\n---\nB\n---\nD"

          self.match(Pro.getTitle(), input) {
            expect($0.getValue()).to(equal("A"))
            expect($0.menus[0].getValue()).to(equal("B"))
            expect($0.menus).to(haveCount(2))
            expect($1).to(beEmpty())
          }
        }

        context("no menu") {
          it("handles base case") {
            self.match(Pro.getTitle(), "My Title") {
              expect($0.getValue()).to(equal("My Title"))
              expect($1).to(beEmpty())
            }
          }

          it("handles no input") {
            self.match(Pro.getTitle(), "") {
              expect($0.getValue()).to(beEmpty())
              expect($1).to(beEmpty())
            }
          }
        }

        context("with menu") {
          it("handles base case") {
            self.match(Pro.getTitle(), "My Title\n---\n") { (title: Title, rem: String) in
              expect(title.getValue()).to(equal("My Title"))
              expect(title.menus).to(haveCount(1))
              expect(title.menus[0].getValue()).to(equal(""))
              expect(rem).to(beEmpty())
            }
          }

          it("handles nested menus") {
            let arg = "My Title\n---\nA\n--B\n----C"
            self.match(Pro.getTitle(), arg) { (title: Title, _) in
              expect(title.getValue()).to(equal("My Title"))
              expect(title.menus).to(haveCount(1))
              expect(title.menus[0].getValue()).to(equal("A"))
              expect(title.menus[0].menus[0].getValue()).to(equal("B"))
              expect(title.menus[0].menus[0].menus[0].getValue()).to(equal("C"))
            }
          }
        }
      }

      describe("menu") {
        let addPrefix = { "\n---\n" + $0 }
        context("params") {
          it("handles params") {
            self.match(Pro.getMenu(), addPrefix("My Menu|")) {
              expect($0.getValue()).to(equal("My Menu"))
              expect($1).to(equal(""))
            }
          }
        }

        context("sub menu") {
          it("has one sub") {
            self.match(Pro.getMenu(), addPrefix("My Menu\n--A")) {
              expect($0.getValue()).to(equal("My Menu"))
              expect($0.menus).to(haveCount(1))
              expect($0.menus[0].getValue()).to(equal("A"))
              expect($1).to(beEmpty())
            }
          }

          it("has +1 subs") {
            self.match(Pro.getMenu(), addPrefix("My Menu\n--A\n--B")) {
              expect($0.getValue()).to(equal("My Menu"))
              expect($0.menus).to(haveCount(2))
              expect($0.menus[0].getValue()).to(equal("A"))
              expect($0.menus[1].getValue()).to(equal("B"))
              expect($1).to(beEmpty())
            }
          }

          it("has menu with params and +1 subs") {
            self.match(Pro.getMenu(), addPrefix("My Menu| size=10\n--A\n--B")) {
              expect($0.getValue()).to(equal("My Menu"))
              expect($0.menus).to(haveCount(2))
              expect($0.menus[0].getValue()).to(equal("A"))
              expect($0.menus[1].getValue()).to(equal("B"))
              expect($1).to(beEmpty())
            }
          }

          it("has subs with params") {
            self.match(Pro.getMenu(), addPrefix("My Menu\n--A| font=X \n--B")) {
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
            self.match(Pro.getMenu(), addPrefix("My Menu")) {
              expect($0.getValue()).to(equal("My Menu"))
              expect($1).to(beEmpty())
            }
          }

          it("handles no input") {
            self.match(Pro.getMenu(), addPrefix("")) {
              expect($0.getValue()).to(equal(""))
              expect($1).to(beEmpty())
            }
          }
        }

        context("params") {
          it("consumes spaces") {
            let arg = addPrefix("My Menu| terminal=true ")
            self.match(Pro.getMenu(), arg) {
              expect($0.getValue()).to(equal("My Menu"))
              expect($1).to(beEmpty())
            }
          }

          it("handles stream") {
            let arg = addPrefix("My Menu| terminal=true")
            self.match(Pro.getMenu(), arg) {
              expect($0.getValue()).to(equal("My Menu"))
            }
          }

          context("terminal") {
            it("it handles true") {
              let arg = addPrefix("My Menu|terminal=true")
              self.match(Pro.getMenu(), arg) {
                expect($0.getValue()).to(equal("My Menu"))
                expect($1).to(beEmpty())
              }
            }

            it("it handles false") {
              let arg = addPrefix("My Menu|terminal=false")
              self.match(Pro.getMenu(), arg) {
                expect($0.getValue()).to(equal("My Menu"))
                expect($1).to(beEmpty())
              }
            }

            it("it handles space between menu and param") {
              let arg = addPrefix("My Menu | terminal=false")
              self.match(Pro.getMenu(), arg) {
                expect($0.getValue()).to(equal("My Menu "))
                expect($1).to(beEmpty())
              }
            }
          }

          context("trim") {
            it("it handles true") {
              let arg = addPrefix("My Menu|terminal=true trim=true")
              self.match(Pro.getMenu(), arg) {
                expect($0.getValue()).to(equal("My Menu"))
                expect($1).to(beEmpty())
              }
            }

            it("it handles false") {
              let arg = addPrefix("My Menu|terminal=false trim=false")
              self.match(Pro.getMenu(), arg) {
                expect($0.getValue()).to(equal("My Menu"))
                expect($1).to(beEmpty())
              }
            }

            it("it handles space between menu and param") {
              let arg = addPrefix("My Menu | terminal=false trim=false")
              self.match(Pro.getMenu(), arg) {
                expect($0.getValue()).to(equal("My Menu "))
                expect($1).to(beEmpty())
              }
            }
          }
        }
      }

      describe("sub menu") {
        context("only submenu") {
          it("handles base case") {
            self.match(Pro.getSubMenu(), "\n--My Sub Menu") {
              expect($0.getValue()).to(equal("My Sub Menu"))
            }
          }

          it("handles no input") {
            self.match(Pro.getSubMenu(), "\n--") {
              expect($0.getValue()).to(equal(""))
            }
          }
        }

        context("sub menus") {
          let addPrefix = { "\n--" + $0 }
          it("has one sub") {
            self.match(Pro.getSubMenu(), addPrefix("Sub\n----A")) {
              expect($0.getValue()).to(equal("Sub"))
              expect($0.menus).to(haveCount(1))
              expect($0.menus[0].getValue()).to(equal("A"))
              expect($1).to(beEmpty())
            }
          }

          it("has +1 subs") {
            self.match(Pro.getSubMenu(), addPrefix("Sub\n----A\n----B")) {
              expect($0.getValue()).to(equal("Sub"))
              expect($0.menus).to(haveCount(2))
              expect($0.menus[0].getValue()).to(equal("A"))
              expect($0.menus[1].getValue()).to(equal("B"))
              expect($1).to(beEmpty())
            }
          }

          it("has menu with params and +1 subs") {
            self.match(Pro.getSubMenu(), addPrefix("Sub\n----A | size=2 \n----B")) {
              expect($0.getValue()).to(equal("Sub"))
              expect($0.menus).to(haveCount(2))
              let sub = $0.menus[0]
              expect(sub.getValue()).to(equal("A "))
              expect($0.menus[1].getValue()).to(equal("B"))
              expect($1).to(beEmpty())
            }
          }

          it("has menu with one dash") {
            self.match(Pro.getSubMenu(), addPrefix("Sub\n-----")) {
              expect($0.getValue()).to(equal("Sub"))
              expect($0.menus).to(haveCount(1))
              let sub = $0.menus[0]
              expect(sub.getValue()).to(equal("-"))
              expect($1).to(beEmpty())
            }
          }

          it("has menu with no content") {
            self.match(Pro.getSubMenu(), addPrefix("Sub\n----")) {
              expect($0.getValue()).to(equal("Sub"))
              expect($0.menus).to(haveCount(1))
              let sub = $0.menus[0]
              expect(sub.getValue()).to(equal(""))
              expect($1).to(beEmpty())
            }
          }

          it("handles nested menus") {
            self.match(Pro.getSubMenu(), addPrefix("Sub\n----A\n------B\n----C")) {
              expect($0.getValue()).to(equal("Sub"))
              expect($0.menus).to(haveCount(2))
              let sub = $0.menus[0]
              expect(sub.menus).to(haveCount(1))
              expect(sub.getValue()).to(equal("A"))
              let sub2 = sub.menus[0]
              expect(sub2.getValue()).to(equal("B"))
              expect($0.menus[1].getValue()).to(equal("C"))
              expect($1).to(beEmpty())
            }
          }
        }
      }

      describe("attributes") {
        describe("href") {
          it("handles base case") {
            self.match(Pro.getHref(), "href=http://google.com") {
              expect($0.getValue()).to(equal("http://google.com"))
            }
          }

          it("handles double quotes") {
            let href = "\"http://google.com\""
            self.match(Pro.getHref(), "href=" + href) {
              expect($0.getValue()).to(equal("http://google.com"))
            }
          }

          it("should be able to contain single quotes if double are used") {
            let href = "\"http://google'''\""
            self.match(Pro.getHref(), "href=" + href) {
              expect($0.getValue()).to(equal("http://google'''"))
            }
          }

          it("should be able to contain double quotes if single are used") {
            let href = "'http://google\"\"\"'"
            self.match(Pro.getHref(), "href=" + href) {
              expect($0.getValue()).to(equal("http://google\"\"\""))
            }
          }

          it("handles single quotes") {
            let href = "'http://google.com'"
            self.match(Pro.getHref(), "href=" + href) {
              expect($0.getValue()).to(equal("http://google.com"))
            }
          }

          it("handles double quotes with no content") {
            let href = "\"\""
            self.match(Pro.getHref(), "href=" + href) {
              expect($0.getValue()).to(equal(""))
            }
          }

          it("handles double quotes with no content") {
            let href = "''"
            self.match(Pro.getHref(), "href=" + href) {
              expect($0.getValue()).to(equal(""))
            }
          }
        }

        describe("font") {
          it("handles base case") {
            self.match(Pro.getFont(), "font=UbuntuMono-Bold") {
              expect($0.getValue()).to(equal("UbuntuMono-Bold"))
            }
          }

          it("handles double quotes") {
            let font = "\"A B C\""
            self.match(Pro.getFont(), "font=" + font) {
              expect($0.getValue()).to(equal("A B C"))
            }
          }

          it("handles single quotes") {
            let font = "'A B C'"
            self.match(Pro.getFont(), "font=" + font) {
              expect($0.getValue()).to(equal("A B C"))
            }
          }

          it("handles double quotes with no content") {
            let font = "\"\""
            self.match(Pro.getFont(), "font=" + font) {
              expect($0.getValue()).to(equal(""))
            }
          }

          it("handles double quotes with no content") {
            let font = "''"
            self.match(Pro.getFont(), "font=" + font) {
              expect($0.getValue()).to(equal(""))
            }
          }
        }

        describe("size") {
          it("handles base case") {
            self.match(Pro.getSize(), "size=12") {
              expect($0.getValue()).to(equal(12))
            }
          }
        }

        describe("bash") {
          it("handles base case without quotes") {
            let bash = "/a/b/c.sh"
            self.match(Pro.getBash(), "bash=" + bash) {
              expect($0.getValue()).to(equal(bash))
            }
          }

          context("quotes") {
            it("handles double quotes") {
              let bash = "\"A B C\""
              self.match(Pro.getBash(), "bash=" + bash) {
                expect($0.getValue()).to(equal("A B C"))
              }
            }

            it("handles single quotes") {
              let bash = "'A B C'"
              self.match(Pro.getBash(), "bash=" + bash) {
                expect($0.getValue()).to(equal("A B C"))
              }
            }

            it("handles double quotes with no content") {
              let bash = "\"\""
              self.match(Pro.getBash(), "bash=" + bash) {
                expect($0.getValue()).to(equal(""))
              }
            }

            it("handles double quotes with no content") {
              let bash = "''"
              self.match(Pro.getBash(), "bash=" + bash) {
                expect($0.getValue()).to(equal(""))
              }
            }
          }

          it("handles base case with quotes") {
            let bash = "\"/a/b/c.sh\""
            self.match(Pro.getBash(), "bash=" + bash) {
              expect($0.getValue()).to(equal("/a/b/c.sh"))
            }
          }
        }

        describe("param") {
          it("handles base case") {
            self.match(Pro.getParam(), "param1=a-value") {
              expect($0.getValue()).to(equal("a-value"))
              expect($1).to(equal(""))
            }
          }

          it("must start with a number") {
            self.failure(Pro.getParam(), "paramX=a-value")
          }
        }

        describe("length") {
          it("handles positive value") {
            self.match(Pro.getLength(), "length=10") {
              expect($0.getValue()).to(equal(10))
            }
          }

          it("it fails on invalid value") {
            // TODO
          }
        }

        func testBase64(_ parser: P<Image>, _ name: String) {
          describe(name) {
            it("handles valid string") {
              self.match(parser, name + "=dGVzdGluZw==") {
                expect($0.getValue()).to(equal("dGVzdGluZw=="))
                expect($1).to(equal(""))
              }
            }

            context("whitespace") {
              let image = "dGVzdGluZw=="
              it("strips pre whitespace") {
                self.match(parser, name + "=    " + image) {
                  expect($0.getValue()).to(equal(image))
                  expect($1).to(equal(""))
                }
              }

              it("strips post whitespace") {
                self.match(parser, name + "=" + image + "  ") {
                  expect($0.getValue()).to(equal(image))
                  expect($1).to(equal(""))
                }
              }

              it("strips whitespace") {
                self.match(parser, name + "=  " + image + "  ") {
                  expect($0.getValue()).to(equal(image))
                  expect($1).to(equal(""))
                }
              }
            }

            context("fails") {
              it("fails on invalid in base64") {
                self.failure(parser, "image=XYZ")
              }

              it("fails on empty string") {
                self.failure(parser, "image=")
              }
            }
          }
        }

        describe("color") {
          describe("english") {
            it("handels base case") {
              self.match(Pro.getColor(), "color=red") {
                expect($0.getValue()).to(equal("red"))
              }
            }
          }

          describe("hex") {
            it("handels base case") {
              self.match(Pro.getColor(), "color=#00AA11") {
                expect($0.getValue()).to(equal("#00AA11"))
              }
            }
          }
        }
      }
    }
  }
}
