import AppKit

enum Pref {
  class Preferences: BaseMenuItem {
    convenience init(pluginPath: String? = App.pluginPath, openAtLogin: Bool =  App.autostart) {
      self.init(title: "Preferences", submenus: [
        Pref.RefreshAll(),
        NSMenuItem.separator(),
        Pref.ChangePluginFolder(),
        Pref.OpenPluginFolder(pluginPath: pluginPath),
        Pref.GetPlugins(),
        NSMenuItem.separator(),
        Pref.OpenAtLogin(openAtLogin: openAtLogin),
        NSMenuItem.separator(),
        Pref.CheckForUpdates(),
        Pref.Quit()
      ])
    }
  }
}
