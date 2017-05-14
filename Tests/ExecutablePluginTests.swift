import Quick
import Files
import Nimble
import BonMot
@testable import BitBar

let aFile = toPath(name: "all.20m", ext: "sh")
class ExecutablePluginTests: Helper {
  override func spec() {
    context("manual script") {
      let defaultFont = ".SFNSText"
      let defaultSize = Int(FontType.item.size)
      let menuBarFontSize = Int(FontType.bar.size)

      item { menu in
        context("top bar") {
          it("handles title") {
            expect(menu).to(have(title: "[Title]"))
            expect(menu).to(have(size: menuBarFontSize))
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

          it("handles length") {
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
                expect(menu).to(have(.noFont))
                expect(menu).toNot(beClickable())
                expect(menu).to(have(image: base64, isTemplate: true))
              }
            }

            it("handles normal") {
              a(menu, at: [16]) { menu in
                expect(menu).to(have(title: ""))
                expect(menu).to(have(.noFont))
                expect(menu).toNot(beClickable())
                expect(menu).to(have(image: base64, isTemplate: false))
              }
            }
          }

          context("base64 image") {
            it("template image") {
              a(menu, at: [15]) { menu in
                expect(menu).to(have(title: ""))
                expect(menu).to(have(.noFont))
                expect(menu).toNot(beClickable())
                expect(menu).to(have(image: base64, isTemplate: true))
              }
            }

            it("handles normal") {
              a(menu, at: [16]) { menu in
                expect(menu).to(have(title: ""))
                // expect(menu).to(have(size: defaultSize))
                expect(menu).to(have(.noFont))
                expect(menu).toNot(beClickable())
                expect(menu).to(have(image: base64, isTemplate: false))
              }
            }
          }

          context("url image") {
            let url = "https://github.com/oleander/bitbar/raw/master/Resources/bitbar-2048.png"

            it("template image") {
              a(menu, at: [17]) { menu in
                expect(menu).toEventually(have(title: ""), timeout: 3000)
                expect(menu).to(have(.noFont))
                expect(menu).toNot(beClickable())
                expect(menu).toEventually(have(imageUrl: url, isTemplate: true), timeout: 3000)
              }
            }

            it("handles normal") {
              a(menu, at: [18]) { menu in
                expect(menu).toEventually(have(title: ""), timeout: 3000)
                expect(menu).to(have(.noFont))
                expect(menu).toNot(beClickable())
                expect(menu).toEventually(have(imageUrl: url, isTemplate: false), timeout: 3000)
              }
            }
          }

          context("ansi") {
            let strike = "strikethrough".styled(with: StringStyle(.strikethrough(.styleSingle, .black)))
            let space = " ".immutable
//            let italic = "italic".styled(with: .italic)
//            let bold = "bold".styled(with: .bold)
            let red = "red".styled(with: StringStyle(.color(.red)))
            let car = ":car:".immutable
            let all = strike + space + car + space + red
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

          context("param") {
            it("handles params") {
              a(menu, at: [29]) { menu in
                expect(menu).to(have(title: "[Args]"))
                expect(menu).to(have(args: ["A", " B ", ""]))
                expect(menu).to(beClickable())
                expect(menu).to(have(subMenuCount: 0))
              }
            }
          }

          context("events") {
            context("no script") {
              context("refresh=true") {
                it("should refresh a menu with no submenus") {
                  a(menu, at: [30]) { menu in
                    expect(menu, when: .clicked).toEventually(have(.broadcasted([.refreshPlugin])))
                  }
                }

                it("should propagate click event to parent") {
                  a(menu, at: [31]) { parent in
                    expect(parent).toEventually(receive([.refreshPlugin], from: [0, 0]))
                  }
                }
              }

              context("refresh=false") {
                it("should not refresh menu") {
                  a(menu, at: [32]) { menu in
                    expect(menu, when: .clicked).toNotEventually(have(.broadcasted([.refreshPlugin])))
                  }
                }

                it("should not propagate click event to parent") {
                  a(menu, at: [33]) { parent in
                    expect(parent).toNotEventually(receive([.refreshPlugin], from: [0, 0]))
                  }
                }
              }
            }

            context("script") {
              context("refresh=true") {
                it("should refresh a menu with no submenus") {
                  a(menu, at: [34]) { menu in
                    expect(menu, when: .clicked).toEventually(have(.broadcasted([.refreshPlugin])), timeout: 1)
                  }
                }

                it("should propagate click event to parent") {
                  a(menu, at: [35]) { parent in
                    expect(parent).toEventually(receive([.refreshPlugin], from: [0, 0]))
                  }
                }
              }

              context("refresh=false") {
                it("should not refresh menu") {
                  a(menu, at: [36]) { menu in
                    expect(menu, when: .clicked).toNotEventually(have(.broadcasted([.refreshPlugin])))
                  }
                }

                it("should not propagate click event to parent") {
                  a(menu, at: [37]) { parent in
                    expect(parent).toNotEventually(receive([.refreshPlugin], from: [0, 0]))
                  }
                }
              }
            }

            context("terminal") {
              context("refresh=true terminal=true") {
                let script = "/usr/bin/whoami"
                let events: [MenuEvent] = [.refreshPlugin, .openScriptInTerminal(script)]
                it("should refresh menu with no submenus") {
                  a(menu, at: [38]) { menu in
                    expect(menu, when: .clicked).toEventually(have(.broadcasted(events)))
                  }
                }

                it("should propagate click event to parent") {
                  a(menu, at: [39]) { parent in
                    expect(parent).toEventually(receive(events, from: [0, 0]))
                  }
                }
              }

              context("refresh=false terminal=false") {
                it("should not refresh menu") {
                  a(menu, at: [40]) { menu in
                    expect(menu, when: .clicked).toNotEventually(have(.broadcasted([.refreshPlugin])))
                  }
                }

                it("should not propagate click event to parent") {
                  a(menu, at: [41]) { parent in
                    expect(parent).toNotEventually(receive([.refreshPlugin], from: [0, 0]))
                  }
                }
              }
            }

            context("href") {
              let events: [MenuEvent] = [.openUrlInBrowser("http://google.com")]
              context("href=...") {
                it("should open href in browser") {
                  a(menu, at: [42]) { menu in
                    expect(menu, when: .clicked).toEventually(have(.broadcasted(events)))
                  }
                }

                it("should propagate open browser event to parent") {
                  a(menu, at: [43]) { parent in
                    expect(parent).toEventually(receive(events, from: [0, 0]))
                  }
                }
              }

              context("refresh=true href=...") {
                it("should also refresh") {
                  a(menu, at: [44]) { menu in
                    expect(menu, when: .clicked).toEventually(have(.broadcasted(events + [.refreshPlugin])))
                  }
                }

                it("should also refresh parent") {
                  a(menu, at: [45]) { parent in
                    expect(parent).toEventually(receive(events + [.refreshPlugin], from: [0, 0]))
                  }
                }
              }
            }

            context("bash error") {
              let events: [MenuEvent] = [.didSetError]
              context("href=...") {
                it("should open href in browser") {
                  a(menu, at: [46]) { menu in
                    expect(menu, when: .clicked).toEventually(have(.broadcasted(events)))
                  }
                }

                it("should propagate open browser event to parent") {
                  a(menu, at: [47]) { parent in
                    expect(parent).toEventually(receive(events, from: [0, 0]))
                  }
                }
              }
            }

            context("default menu items") {
              context("updated time ago") {
                a(menu, at: [menu.items.count - 3]) { menu in
                  beforeEach { menu.onWillBecomeVisible() }

                  it("should have the proper title") {
                    expect(menu).toEventually(contain(title: "Updated"))
                  }

                  it("should not be clickable") {
                    expect(menu).toNot(beClickable())
                  }

                  it("should have no submenus") {
                    expect(menu).to(haveNoSubMenus())
                  }

                  it("should have shortcut R") {
                    expect(menu).to(have(.noShortcut))
                  }

                  it("should not broadcast anything") {
                    expect(menu, when: .clicked).to(have(.broadcasted([])))
                  }
                }
              }

              context("run in terminal") {
                a(menu, at: [menu.items.count - 2]) { menu in
                  it("should have the proper title") {
                    expect(menu).to(have(title: "Run in Terminal…"))
                  }

                  it("should be clickable") {
                    expect(menu).to(beClickable())
                  }

                  it("should have no submenus") {
                    expect(menu).to(haveNoSubMenus())
                  }

                  it("should have shortcut R") {
                    expect(menu).to(have(shortcut: "o"))
                  }

                  it("should broadcast refresh event on click") {
                    expect(menu, when: .clicked).to(have(.broadcasted([.runInTerminal])))
                  }
                }
              }

              context("Preferences") {
                a(menu, at: [menu.items.count - 1]) { menu in
                  it("should have the proper title") {
                    expect(menu).to(have(title: "Preferences"))
                  }

                  it("should be clickable") {
                    expect(menu).to(beClickable())
                  }

                  it("should not broadcast anything") {
                    expect(menu, when: .clicked).to(have(.broadcasted([])))
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
