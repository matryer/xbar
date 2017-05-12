extension Pref {
  class OpenPluginFolder: MenuItem {
    required convenience init(pluginPath: String?) {
      self.init(title: "Open Plugin Folder…", isClickable: pluginPath != nil)
    }

    override func onDidClick() {
      broadcast(.openPluginFolder)
    }
  }
}
