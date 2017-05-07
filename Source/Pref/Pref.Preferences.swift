import Cocoa

enum Pref {
  class Preferences: BaseMenuItem {
     convenience init() {
      self.init(title: "Preferences", submenus: [
        Pref.RefreshAll(),
        NSMenuItem.separator(),
        Pref.ChangePluginFolder(),
        Pref.OpenPluginFolder(),
        Pref.GetPlugins(),
        NSMenuItem.separator(),
        Pref.OpenAtLogin(),
        NSMenuItem.separator(),
        Pref.CheckForUpdates(),
        Pref.Quit()
      ])
    }
  }
}
