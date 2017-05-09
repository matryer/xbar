extension Pref {
  class RefreshAll: MenuItem {
    required convenience  init() {
      self.init(title: "Refresh All", shortcut: "r")
    }

    override func onDidClick() {
      broadcast(.refreshAll)
    }
  }
}
