extension Pref {
  class GetPlugins: BaseMenuItem {
    required convenience init() {
      self.init(title: "Get Plugins…")
    }

    override func onDidClick() {
      broadcast(.openWebsite)
    }
  }
}
