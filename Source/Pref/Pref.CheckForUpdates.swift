extension Pref {
  class CheckForUpdates: BaseMenuItem {
    required convenience init() {
      self.init(title: "Check for Updates…")
    }

    override func onDidClick() {
      broadcast(.checkForUpdates)
    }
  }
}
