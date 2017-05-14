extension Pref {
  class CheckForUpdates: MenuItem {
    required convenience init() {
      self.init(title: "Check for Updates…", isClickable: true)
    }

    override func onDidClick() {
      broadcast(.checkForUpdates)
    }
  }
}
