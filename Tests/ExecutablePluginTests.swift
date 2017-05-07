import Quick
import Nimble
import Attr
import Async
@testable import BitBar

class ExecutablePluginTests: Helper {
  override func spec() {
    context("manual script") {
      let file = File("test", 10000, "sh")
      let path = toFile("all.sh")
      let bar = TestBar()
      let plugin = ExecutablePlugin(path: path, file: file, item: bar)
      let defaultFont = ".AppleSystemUIFont"
      let defaultSize = 14


      item(plugin) { menu in
        context("top bar") {
          it("handles title") {
            expect(menu).to(have(title: "[Title]"))
            expect(menu).to(have(size: defaultSize))
            expect(menu).to(have(font: defaultFont))
          }
        }

        context("sub menus level #1") {
          it("handles color") {
            a(menu, at: [0]) { menu in
              expect(menu).to(have(title: "[Color(red)]"))
              expect(menu).to(have(foreground: .red))
              expect(menu).toNot(beClickable())
              expect(menu).to(have(size: defaultSize))
              expect(menu).to(have(font: defaultFont))
            }
          }

          it("handles href") {
            a(menu, at: [1]) { menu in
              expect(menu).to(have(title: "[Href]"))
              expect(menu).to(have(href: "http://google.com"))
              expect(menu).to(beClickable())
              expect(menu).to(have(size: defaultSize))
              expect(menu).to(have(font: defaultFont))
            }
          }

          context("href") {
            it("handles =true") {
              a(menu, at: [2]) { menu in
                expect(menu).to(have(title: "[Checked true]"))
                expect(menu).to(beChecked())
                expect(menu).to(have(size: defaultSize))
                expect(menu).notTo(beClickable())
                expect(menu).to(have(font: defaultFont))
              }
            }

            it("handles =false") {
              a(menu, at: [3]) { menu in
                expect(menu).to(have(title: "[Checked false]"))
                expect(menu).toNot(beChecked())
                expect(menu).to(have(size: defaultSize))
                expect(menu).notTo(beClickable())
                expect(menu).to(have(font: defaultFont))
              }
            }
          }

          context("alternate") {
            it("handles =true") {
              a(menu, at: [4]) { menu in
                expect(menu).to(have(title: "[Alternate true]"))
                expect(menu).to(beAlternatable())
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
              }
            }

            it("handles =false") {
              a(menu, at: [5]) { menu in
                expect(menu).to(have(title: "[Alternate false]"))
                expect(menu).toNot(beAlternatable())
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
              }
            }
          }

          it("handles truncate") {
            a(menu, at: [6]) { menu in
              expect(menu).to(have(title: "[Tru…"))
              expect(menu).notTo(beClickable())
              expect(menu).to(have(size: defaultSize))
              expect(menu).to(have(font: defaultFont))
            }
          }

          it("handles size") {
            a(menu, at: [7]) { menu in
              expect(menu).to(have(title: "[Font Size 10]"))
              expect(menu).to(have(size: 10))
              expect(menu).notTo(beClickable())
              expect(menu).to(have(font: defaultFont))
            }
          }

          it("handles font family") {
            a(menu, at: [8]) { menu in
              expect(menu).to(have(title: "[Font Family Times New Roman]"))
              expect(menu).to(have(font: "TimesNewRomanPSMT"))
              expect(menu).to(have(size: defaultSize))
              expect(menu).notTo(beClickable())
            }
          }

          context("refresh") {
            it("handles =true") {
              a(menu, at: [9]) { menu in
                expect(menu).to(have(title: "[Refresh true]"))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).to(beClickable())
              }
            }

            it("handles =false") {
              a(menu, at: [10]) { menu in
                expect(menu).to(have(title: "[Refresh false]"))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
              }
            }
          }

          context("emojize") {
            it("handles =true") {
              a(menu, at: [11]) { menu in
                expect(menu).to(have(title: "[🍄 true]"))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
              }
            }

            it("handles =false") {
              a(menu, at: [12]) { menu in
                expect(menu).to(have(title: "[:mushroom: false]"))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
              }
            }
          }

          context("terminal") {
            it("handles =true") {
              a(menu, at: [13]) { menu in
                expect(menu).to(have(title: "[Terminal true]"))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).to(beClickable())
              }
            }

            it("handles =false") {
              a(menu, at: [14]) { menu in
                expect(menu).to(have(title: "[Terminal false]"))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).to(beClickable())
              }
            }
          }

          context("base64 image") {
            it("template image") {
              a(menu, at: [15]) { menu in
                expect(menu).to(have(title: ""))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
                expect(menu).to(have(image: base64, isTemplate: true))
              }
            }

            it("handles normal") {
              a(menu, at: [16]) { menu in
                expect(menu).to(have(title: ""))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
                expect(menu).to(have(image: base64, isTemplate: false))
              }
            }
          }

          context("base64 image") {
            it("template image") {
              a(menu, at: [15]) { menu in
                expect(menu).to(have(title: ""))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
                expect(menu).to(have(image: base64, isTemplate: true))
              }
            }

            it("handles normal") {
              a(menu, at: [16]) { menu in
                expect(menu).to(have(title: ""))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
                expect(menu).to(have(image: base64, isTemplate: false))
              }
            }
          }

          context("url image") {
            let url = "https://www.w3schools.com/css/img_flowers.jpg"

            it("template image") {
              a(menu, at: [17]) { menu in
                expect(menu).toEventually(have(title: ""))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
                expect(menu).toEventually(have(imageUrl: url , isTemplate: true))
              }
            }

            it("handles normal") {
              a(menu, at: [18]) { menu in
                expect(menu).toEventually(have(title: ""))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
                expect(menu).toEventually(have(imageUrl: url, isTemplate: false))
              }
            }
          }

          context("ansi") {
            let strike = "strikethrough".mutable().style(with: .strikethrough)
            let space = " ".mutable()
            let italic = "italic".mutable().style(with: .italic)
            let bold = "bold".mutable().style(with: .bold)
            let red = "red".mutable().style(with: .foreground(.red))
            let car = ":car:".mutable()
            let all = strike + space + italic + space + car + space + bold + space + red
            it("handles combination") {
              a(menu, at: [19]) { menu in
                expect(menu).to(have(title: all))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
              }
            }
          }

          context("dropdown") {
            it("handles =true") {
              a(menu, at: [20]) { menu in
                expect(menu).to(have(title: "[Dropdown true]"))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).to(beClickable())
                expect(menu).to(have(subMenuCount: 1))
              }
            }

            it("handles =true") {
              a(menu, at: [21]) { menu in
                expect(menu).to(have(title: "[Dropdown false]"))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
                expect(menu).to(have(subMenuCount: 0))
              }
            }
          }

          context("sub menus") {
            it("handles nested menus") {
              a(menu, at: [22]) { menu in
                expect(menu).to(have(title: "Menu 1"))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).to(beClickable())
                expect(menu).to(have(subMenuCount: 2))

                a(menu, at: [0]) { menu in
                  expect(menu).to(have(title: "Menu 2"))
                  expect(menu).to(have(size: defaultSize))
                  expect(menu).to(have(font: defaultFont))
                  expect(menu).to(beClickable())
                  expect(menu).to(have(subMenuCount: 2))

                  a(menu, at: [0]) { menu in
                    expect(menu).to(have(title: "Menu 3"))
                    expect(menu).to(have(size: defaultSize))
                    expect(menu).to(have(font: defaultFont))
                    expect(menu).to(beClickable())
                    expect(menu).to(have(subMenuCount: 1))

                    a(menu, at: [0]) { menu in
                      expect(menu).to(have(title: "Menu 4"))
                      expect(menu).to(have(size: defaultSize))
                      expect(menu).to(have(font: defaultFont))
                      expect(menu).toNot(beClickable())
                      expect(menu).to(have(subMenuCount: 0))
                    }
                  }

                  a(menu, at: [1]) { menu in
                    expect(menu).to(have(title: "Menu 5"))
                    expect(menu).to(have(size: defaultSize))
                    expect(menu).to(have(font: defaultFont))
                    expect(menu).toNot(beClickable())
                    expect(menu).to(have(subMenuCount: 0))
                  }
                }

                a(menu, at: [1]) { menu in
                  expect(menu).to(have(title: "Menu 6"))
                  expect(menu).to(have(size: defaultSize))
                  expect(menu).to(have(font: defaultFont))
                  expect(menu).toNot(beClickable())
                  expect(menu).to(have(subMenuCount: 0))
                }
              }

              a(menu, at: [23]) { menu in
                expect(menu).to(have(title: "Menu 7"))
                expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(font: defaultFont))
                expect(menu).toNot(beClickable())
                expect(menu).to(have(subMenuCount: 0))
              }
            }
          }
          context("separator") {
            it("has separator on level 0") {
              a(menu, at: [24]) { menu in
                expect(menu).to(beASeparator())
                expect(menu).toNot(beClickable())
                expect(menu).to(have(subMenuCount: 0))
              }
            }

            it("has separators in sub menus") {
              a(menu, at: [25, 0]) { menu in
                expect(menu).to(have(title: "Menu 9"))
                expect(menu).toNot(beASeparator())
                expect(menu).toNot(beClickable())
                expect(menu).to(have(subMenuCount: 0))
              }

              a(menu, at: [25, 1]) { menu in
                expect(menu).to(beASeparator())
                expect(menu).toNot(beClickable())
                expect(menu).to(have(subMenuCount: 0))
              }

              a(menu, at: [25, 2]) { menu in
                expect(menu).to(have(title: "Menu 10"))
                expect(menu).toNot(beASeparator())
                expect(menu).toNot(beClickable())
                expect(menu).to(have(subMenuCount: 0))
              }
            }
          }

          context("trimmed") {
            it("handles =true") {
              a(menu, at: [26]) { menu in
                expect(menu).to(beTrimmed())
                expect(menu).toNot(beClickable())
                expect(menu).to(have(subMenuCount: 0))
              }
            }

            it("handles =false") {
              a(menu, at: [27]) { menu in
                expect(menu).toNot(beTrimmed())
                expect(menu).toNot(beClickable())
                expect(menu).to(have(subMenuCount: 0))
              }
            }
          }

          context("href") {
            it("handles base case") {
              a(menu, at: [28]) { menu in
                expect(menu).to(have(href: "http://google.com"))
                expect(menu).to(beClickable())
                expect(menu).to(have(subMenuCount: 0))
              }
            }
          }
        }
      }
    }
  }
}

