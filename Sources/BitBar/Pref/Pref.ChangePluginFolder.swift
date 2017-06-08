extension Pref {
  class ChangePluginFolder: MenuItem {
    required convenience init() {
      self.init(title: "Change Plugin Folder…", shortcut: ",")
    }

    override func onDidClick() {
      broadcast(.changePluginPath)
    }
  }
}
