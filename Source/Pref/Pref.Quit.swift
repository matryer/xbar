extension Pref {
  class Quit: MenuItem {
    required convenience init() {
      self.init(title: "Quit", shortcut: "q")
    }

    override func onDidClick() {
      broadcast(.quitApplication)
    }
  }
}
