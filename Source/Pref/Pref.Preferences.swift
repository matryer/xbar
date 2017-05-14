import AppKit

enum Pref {
  class Preferences: MenuItem {
    convenience init(pluginPath: String? = App.pluginPath, openAtLogin: Bool =  App.autostart, prefs: [NSMenuItem] = []) {

      var newPrefs = prefs
      if !newPrefs.isEmpty {
        newPrefs.append(NSMenuItem.separator())
      }

      self.init(title: "Preferences", submenus: [
        Pref.RefreshAll(),
        NSMenuItem.separator(),
        Pref.ChangePluginFolder(),
        Pref.OpenPluginFolder(pluginPath: pluginPath),
        Pref.GetPlugins(),
        NSMenuItem.separator()
      ] + newPrefs + [
        Pref.OpenAtLogin(openAtLogin: openAtLogin),
        NSMenuItem.separator(),
        Pref.CheckForUpdates(),
        Pref.Quit()
      ])
    }
  }
}
