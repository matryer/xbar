extension Pref {
  class CheckForUpdates: MenuItem {
    required convenience init() {
      self.init(title: "Check for Updates…")
    }

    override func onDidClick() {
      broadcast(.checkForUpdates)
    }
  }
}
