extension Pref {
  class RefreshAll: BaseMenuItem {
    required convenience  init() {
      self.init(title: "Refresh All", shortcut: "r")
    }

    override func onDidClick() {
      broadcast(.refreshAll)
    }
  }
}
