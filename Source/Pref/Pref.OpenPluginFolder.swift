extension Pref {
  class OpenPluginFolder: BaseMenuItem {
    required convenience init() {
      self.init(title: "Open Plugin Folder…", isClickable: App.pluginPath != nil)
    }

    override func onDidClick() {
      broadcast(.openPluginFolder)
    }
  }
}
