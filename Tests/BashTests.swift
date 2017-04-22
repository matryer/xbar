import Quick
import Nimble
import EmitterKit
import Attr
@testable import BitBar

private let examplePlugin = App.path(forResource: "sub.2m.sh")
private let bash = "/usr/local/opt/coreutils/libexec/gnubin/date"
var listener: Listener?
class BashTests: Helper {
  override func spec() {
    let setup = { (_ input: String..., block: @escaping (Menuable) -> Void) in
      self.match(Pro.menu, input.joined() + "\n") { (menu) in
        block(menu)
      }
    }

    let up = { (_ input: String..., block: @escaping (Title) -> Void) in
      self.match(Pro.title, input.joined() + "\n") { (menu) in
        block(menu)
      }
    }

    context("parser") {
      let parser = Pro.getBash()

      it("handles base case without quotes") {
        expect(the(parser, with: "bash=/a/c.sh")).to(output("/a/c.sh"))
      }

      context("quotes") {
        it("handles double quotes") {
          // TODO: Fails
//          let bash = "\"A B C\""
//          expect(the(parser, with: "bash=" + bash)).to(output(bash))
        }

        it("handles single quotes") {
          let bash = "'A B C'"
          expect(the(parser, with: "bash=" + bash)).to(output("A B C"))
        }

        it("handles double quotes with no content") {
          let bash = "\"\""
          expect(the(parser, with: "bash=" + bash)).to(output(""))
        }

        it("handles double quotes with no content") {
          let bash = "''"
          expect(the(parser, with: "bash=" + bash)).to(output(""))
        }
      }

      it("handles base case with quotes") {
        let bash = "\"/a/b/c.sh\""
        expect(the(parser, with: "bash=" + bash)).to(output("/a/b/c.sh"))
      }
    }

    context("clickable") {
      it("is clickable when terminal=true") {
        setup("A | terminal=true bash='/a/b/c'") { menu in
          expect(the(menu)).to(beClickable())
        }
      }

      it("is clickable when terminal=false") {
        setup("A | terminal=false bash='/a/b/c'") { menu in
          expect(the(menu)).to(beClickable())
        }
      }

      it("is not clickable only using terminal=false") {
        setup("A | terminal=false") { menu in
          expect(the(menu)).toNot(beClickable())
        }
      }

      it("is not clickable only using terminal=true") {
        setup("A | terminal=true") { menu in
          expect(the(menu)).toNot(beClickable())
        }
      }
    }

    context("events") {
      it("it calls bash script in the background") {
        setup("A | bash=\(bash)") { menu in
          (menu as! Menu).trigger()
          var ok = false
          listener = App.onMessage2 { message in
            switch message {
            case let .bashScriptFinished(output):
              ok = true
              expect(String(describing: output)).to(contain("Succeeded (0)"))
            default:
              ok = false
            }
          }
          expect(ok).toEventually(beTrue())
          expect(the(menu)).to(beClickable())
        }
      }

      it("opens bash script in background when terminal=false") {
        setup("A | terminal=false bash=\(bash)") { menu in
          (menu as! Menu).trigger()
          var finished = false
          listener = App.onMessage2 { message in
            switch message {
            case let .bashScriptFinished(output):
              expect(String(describing: output)).to(contain("Succeeded (0)"))
              finished = true
            default:
              finished = false
            }
          }
          expect(finished).toEventually(beTrue())
          expect(the(menu)).to(beClickable())
        }
      }

      it("opens up a terminal instead of running in the background") {
        setup("A | terminal=true bash=\(bash)") { menu in
          var finish = false
          listener = App.onMessage2 { message in
            switch message {
            case let .bashScriptOpened(path):
              expect(path).to(equal(bash))
              finish = true
            default:
              finish = false
            }
          }

          (menu as! Menu).trigger()
          expect(the(menu)).to(beClickable())
          expect(finish).toEventually(beTrue())
        }
      }

      context("refresh") {
        context("bash") {
          it("should refresh menu when bash script finishes") {
            setup("A | refresh=true bash=\(bash)") { menu in
              var actions = [Int]()
              listener = App.onMessage2 { message in
                switch message {
                case .bashScriptFinished:
                  actions.append(1)
                case .menuTriggeredRefresh:
                  actions.append(2)
                default:
                  actions.append(3)
                }
              }

              (menu as! Menu).trigger()
              expect(the(menu)).to(beClickable())
              expect(actions).toEventually(equal([1,2]))
              expect(actions).toNotEventually(equal([1,2,3]))
            }
          }
        }
      }

      context("title") {
        context("refresh.bash") {
          it("should handle a submenu containing a bash script") {
            up("A\n---\nB | bash=\(bash) refresh=true") { title in
              var actions = [Int]()
              listener = App.onMessage2 { message in
                switch message {
                case .bashScriptFinished:
                  actions.append(1)
                case .menuTriggeredRefresh:
                  actions.append(2)
                case .titleTriggeredRefresh:
                  actions.append(3)
                default:
                  actions.append(4)
                }
              }

              let menu = title.menus[0]
              menu.trigger()
              expect(the(menu)).to(beClickable())
              expect(actions).toEventually(equal([1,2,3]))
              expect(actions).toNotEventually(equal([1,2,3,4]))
            }
          }

          it("should not refresh title if refresh is set to false") {
            up("A\n---\nB | bash=\(bash) refresh=false") { title in
              var actions = [Int]()
              listener = App.onMessage2 { message in
                switch message {
                case .bashScriptFinished:
                  actions.append(1)
                case .menuTriggeredRefresh:
                  actions.append(2)
                case .titleTriggeredRefresh:
                  actions.append(3)
                default:
                  actions.append(4)
                }
              }

              let menu = title.menus[0]
              menu.trigger()
              expect(the(menu)).to(beClickable())
              expect(actions).toNotEventually(equal([1,2,3]))
            }
          }

          it("should refresh title if no bash script exist") {
            up("A\n---\nB | refresh=true") { title in
              var actions = [Int]()
              listener = App.onMessage2 { message in
                switch message {
                case .bashScriptFinished:
                  actions.append(1)
                case .menuTriggeredRefresh:
                  actions.append(2)
                case .titleTriggeredRefresh:
                  actions.append(3)
                default:
                  actions.append(4)
                }
              }

              let menu = title.menus[0]
              menu.trigger()
              expect(the(menu)).to(beClickable())
              expect(actions).toEventually(equal([2,3]))
            }
          }

          it("should not refresh title if refresh = false") {
            up("A\n---\nB | refresh=false") { title in
              var actions = [Int]()
              listener = App.onMessage2 { message in
                switch message {
                case .bashScriptFinished:
                  actions.append(1)
                case .menuTriggeredRefresh:
                  actions.append(2)
                case .titleTriggeredRefresh:
                  actions.append(3)
                default:
                  actions.append(4)
                }
              }

              let menu = title.menus[0]
              menu.trigger()
              expect(the(menu)).notTo(beClickable())
              expect(actions).toNotEventually(contain(3))
            }
          }
        }

        context("refresh.bash.terminal") {
          it("should open terminal then refresh") {
            up("A\n---\nB | bash=\(bash) refresh=true terminal=true") { title in
              var actions = [Int]()
              listener = App.onMessage2 { message in
                switch message {
                case let .bashScriptOpened(script):
                  actions.append(1)
                  expect(script).to(equal(bash))
                case .bashScriptFinished:
                  actions.append(2)
                case .menuTriggeredRefresh:
                  actions.append(3)
                case .titleTriggeredRefresh:
                  actions.append(4)
                }
              }

              let menu = title.menus[0]
              menu.trigger()
              expect(the(menu)).to(beClickable())
              expect(actions).toEventually(contain([1,3,4]))
            }
          }

          it("should not open terminal when terminal=false") {
            up("A\n---\nB | bash=\(bash) refresh=true terminal=false") { title in
              var actions = [Int]()
              listener = App.onMessage2 { message in
                switch message {
                case .bashScriptOpened:
                  actions.append(1)
                case .bashScriptFinished:
                  actions.append(2)
                case .menuTriggeredRefresh:
                  actions.append(3)
                case .titleTriggeredRefresh:
                  actions.append(4)
                  listener = nil
                }
              }

              let menu = title.menus[0]
              menu.trigger()
              expect(the(menu)).to(beClickable())
              expect(actions).toEventually(equal([2,3,4]))
            }
          }

          it("should open terminal but not refresh") {
            up("A\n---\nB | bash=\(bash) refresh=false terminal=true") { title in
              var actions = [Int]()
              listener = App.onMessage2 { message in
                switch message {
                case .bashScriptOpened:
                  actions.append(1)
                case .bashScriptFinished:
                  actions.append(2)
                case .menuTriggeredRefresh:
                  actions.append(3)
                case .titleTriggeredRefresh:
                  actions.append(4)
                }
              }

              let menu = title.menus[0]
              menu.trigger()
              expect(the(menu)).to(beClickable())
              expect(actions).toEventually(equal([1]))
            }
          }
        }


        context("args") {
          let path = toFile("args.sh")
          it("should handle base case") {
            up("A\n---\nB | bash=\(path) param1=ABC") { title in
              var actions = [Int]()
              listener = App.onMessage2 { message in
                switch message {
                case .bashScriptOpened:
                  actions.append(1)
                case let .bashScriptFinished(output):
                  actions.append(2)
                  expect(output.toString()).to(contain("ABC"))
                case .menuTriggeredRefresh:
                  actions.append(3)
                case .titleTriggeredRefresh:
                  actions.append(4)
                }
              }

              let menu = title.menus[0]
              menu.trigger()
              expect(the(menu)).to(beClickable())
              expect(actions).toEventually(contain([2]))
            }
          }
          
          // TODO: Fix
//          it("should handle unsorted params") {
//            up("A\n---\nB | bash=\(path) param2=ABC param1=DEF") { title in
//              var actions = [Int]()
//              listener = App.onMessage2 { message in
//                switch message {
//                case let .bashScriptFinished(output):
//                  expect(output.toString()).to(contain("DEF ABC"))
//                  actions.append(0)
//                default: break
//                }
//              }
//
//              let menu = title.menus[0]
//              menu.trigger()
//              expect(the(menu)).to(beClickable())
//              expect(actions).toEventually(equal([0]))
//            }
//          }
        }

        context("cascading click event") {
          it("should be able to cascade from child to top parent") {
            up("A\n---\nB\n--C\n----D\n------E\n--------F|refresh=true\n") { title in
              var actions = [Int]()
              listener = App.onMessage2 { message in
                switch message {
                case .menuTriggeredRefresh:
                  actions.append(1)
                case .titleTriggeredRefresh:
                  actions.append(2)
                default: break
                }
              }

              let menu = title.menus[0].menus[0].menus[0].menus[0].menus[0]
              menu.trigger()
              expect(the(menu)).to(beClickable())
              expect(the(menu)).to(have(title: "F"))
              expect(actions).toEventually(equal([1,2]))
            }
          }
        }
      }
    }
  }
}
