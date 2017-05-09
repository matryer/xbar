import Quick
import Nimble
@testable import BitBar

class PreferenceMenuTests: Helper {
  override func spec() {
    a(.success(Pref.Preferences(pluginPath: nil))) { base in
      it("should have a base menu") {
        expect(base).to(have(title: "Preferences"))
        expect(base).to(beClickable())
        expect(base).to(have(subMenuCount: 10))
      }

      context("sub menus") {
        context("#1 refresh all") {
          a(base, at: [0]) { menu in
            it("should have the proper title") {
              expect(menu).to(have(title: "Refresh All"))
            }

            it("should be clickable") {
              expect(menu).to(beClickable())
            }

            it("should have no submenus") {
              expect(menu).to(haveNoSubMenus())
            }

            it("should have shortcut R") {
              expect(menu).to(have(shortcut: "r"))
            }

            it("should broadcast refresh event on click") {
              expect(menu, when: .clicked).to(have(.broadcasted([.refreshAll])))
            }
          }
        }

        context("#2 separator") {
          a(base, at: [1]) { menu in
            it("should be a separator") {
              expect(menu).to(beASeparator())
            }
          }
        }

        context("#3 change plugin folder") {
          a(base, at: [2]) { menu in
            it("should have the proper title") {
              expect(menu).to(have(title: "Change Plugin Folder…"))
            }

            it("should be clickable") {
              expect(menu).to(beClickable())
            }

            it("should have no submenus") {
              expect(menu).to(haveNoSubMenus())
            }

            it("should have shortcut ,") {
              expect(menu).to(have(shortcut: ","))
            }

            it("should fire a global refresh event") {
              expect(menu, when: .clicked).to(have(.broadcasted([.changePluginPath])))
            }
          }
        }

        context("#4 open plugin folder") {
          a(base, at: [3]) { menu in
            it("should have the proper title") {
              expect(menu).to(have(title: "Open Plugin Folder…"))
            }

            it("should have no submenus") {
              expect(menu).to(have(.noSubMenus))
            }

            it("should have no shortcut") {
              expect(menu).to(have(.noShortcut))
            }
          }
        }

        context("#5 get plugin plugins") {
          a(base, at: [4]) { menu in
            it("should have the proper title") {
              expect(menu).to(have(title: "Get Plugins…"))
            }

            it("should be clickable") {
              expect(menu).to(beClickable())
            }

            it("should have no submenus") {
              expect(menu).to(have(.noSubMenus))
            }

            it("should have no shortcut") {
              expect(menu).to(have(.noShortcut))
            }

            it("should broadcast 'open website' event on click") {
              expect(menu, when: .clicked).to(have(.broadcasted([.openWebsite])))
            }
          }
        }

        context("#6 separator") {
          a(base, at: [5]) { menu in
            it("should be a separator") {
              expect(menu).to(beASeparator())
            }
          }
        }

        context("#7 open at login") {
          a(base, at: [6]) { menu in
            it("should have the proper title") {
              expect(menu).to(have(title: "Open at Login"))
            }

            it("should be clickable") {
              expect(menu).to(beClickable())
            }

            it("should have no submenus") {
              expect(menu).to(have(.noSubMenus))
            }

            it("should have no shortcut") {
              expect(menu).to(have(.noShortcut))
            }
          }
        }

        context("#8 separator") {
          a(base, at: [7]) { menu in
            it("should be a separator") {
              expect(menu).to(beASeparator())
            }
          }
        }

        context("#9 check for updates") {
          a(base, at: [8]) { menu in
            it("should have the proper title") {
              expect(menu).to(have(title: "Check for Updates…"))
            }

            it("should be clickable") {
              expect(menu).to(beClickable())
            }

            it("should have no submenus") {
              expect(menu).to(have(.noSubMenus))
            }

            it("should have no shortcut") {
              expect(menu).to(have(.noShortcut))
            }

            it("should broadcast event on click") {
              expect(menu, when: .clicked).to(have(.broadcasted([.checkForUpdates])))
            }
          }
        }

        context("#10 quit") {
          a(base, at: [9]) { menu in
            it("should have the proper title") {
              expect(menu).to(have(title: "Quit"))
            }

            it("should be clickable") {
              expect(menu).to(beClickable())
            }

            it("should have no submenus") {
              expect(menu).to(have(.noSubMenus))
            }

            it("should have no shortcut") {
              expect(menu).to(have(shortcut: "q"))
            }

            it("should broadcast event on click") {
              expect(menu, when: .clicked).to(have(.broadcasted([.quitApplication])))
            }
          }
        }
      }

      context("open plugin folder") {
        context("plugin path") {
          a(.success(Pref.Preferences(pluginPath: "/a/b/c")), at: [3]) { menu in
            it("should be clickable") {
              expect(menu).to(beClickable())
            }

            it("should broadcast click event") {
              expect(menu, when: .clicked).to(have(.broadcasted([.openPluginFolder])))
            }
          }
        }

        context("no plugin path") {
          a(.success(Pref.Preferences(pluginPath: nil)), at: [3]) { menu in
            it("should be clickable") {
              expect(menu).toNot(beClickable())
            }

            it("should not fire open plugin event") {
              expect(menu, when: .clicked).toNot(have(.broadcasted([.openPluginFolder])))
            }
          }
        }
      }

      context("open at login") {
        var parent: W<Menuable>!

        context("init state is to not open") {
          beforeEach {
            parent = .success(Pref.Preferences(openAtLogin: false))
          }

          it("should not be checked") {
            a(parent, at: [6]) { menu in
              expect(menu).toNot(beChecked())
            }
          }

          it("should be checked when clicked") {
            a(parent, at: [6]) { menu in
              expect(menu, when: .clicked).to(beChecked())
            }
          }

          it("should broadcast event") {
            a(parent, at: [6]) { menu in
              expect(menu, when: .clicked).to(have(.broadcasted([.openOnLogin])))
              expect(menu, when: .clicked).to(have(.broadcasted([.doNotOpenOnLogin])))
            }
          }
        }

        context("init state is to not open") {
          beforeEach {
            parent = .success(Pref.Preferences(openAtLogin: true))
          }

          it("should not be checked") {
            a(parent, at: [6]) { menu in
              expect(menu).to(beChecked())
            }
          }

          it("should be checked when clicked") {
            a(parent, at: [6]) { menu in
              expect(menu, when: .clicked).toNot(beChecked())
            }
          }

          it("should broadcast event") {
            a(parent, at: [6]) { menu in
              expect(menu, when: .clicked).to(have(.broadcasted([.doNotOpenOnLogin])))
              expect(menu, when: .clicked).to(have(.broadcasted([.openOnLogin])))
            }
          }
        }
      }


      //   Pref.RefreshAll(),
      //   NSMenuItem.separator(),
      //   Pref.ChangePluginFolder(),
      //   Pref.OpenPluginFolder(),
      //   Pref.GetPlugins(),
      //   NSMenuItem.separator(),
      //   Pref.OpenAtLogin(),
      //   NSMenuItem.separator(),
      //   Pref.CheckForUpdates(),
      //   Pref.Quit()
      // ])

    }
  }
}
