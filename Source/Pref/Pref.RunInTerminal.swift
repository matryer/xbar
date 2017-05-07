extension Pref {
  class RunInTerminal: BaseMenuItem {
    required convenience init() {
      self.init(title: "Run in Terminal…", shortcut: "o")
    }

    override func onDidClick() {
      broadcast(.runInTerminal)
    }
  }
}
