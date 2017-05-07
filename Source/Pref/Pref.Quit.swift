extension Pref {
  class Quit: BaseMenuItem {
    required convenience init() {
      self.init(title: "Quit", shortcut: "q")
    }

    override func onDidClick() {
      broadcast(.quitApplication)
    }
  }
}
