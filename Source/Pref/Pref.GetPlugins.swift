extension Pref {
  class GetPlugins: MenuItem {
    required convenience init() {
      self.init(title: "Get Plugins…")
    }

    override func onDidClick() {
      broadcast(.openWebsite)
    }
  }
}
