import AppKit

class PreferenceMenu: NSMenuItem, NSMenuDelegate {
  weak var prefDelegate: PreferenceMenuDelegate?

  init(delegate: PreferenceMenuDelegate?) {
    prefDelegate = delegate

    super.init(title: "Preferences", action: nil, keyEquivalent: "")

    submenu = NSMenu()
    // TODO: Re-add
    // submenu?.addItem(MenuItem(title: "Refresh All", key: "r") {
    //   self.prefDelegate?.preferenceDidRefreshAll()
    // })
    //
    // submenu?.addItem(NSMenuItem.separator())
    //
    // submenu?.addItem(MenuItem(title: "Change Plugin Folder…") {
    //   // TODO: Implement this
    // })
    //
    // submenu?.addItem(MenuItem(title: "Open Plugin Folder…") {
    //   // TODO: Implement this
    // })
    //
    // submenu?.addItem(MenuItem(title: "Get Plugins…") {
    //   // TODO: Implement this
    // })
    //
    // submenu?.addItem(NSMenuItem.separator())
    //
    // submenu?.addItem(MenuItem(title: "Check for Updates…") {
    //   // TODO: Implement this
    // })
    //
    // submenu?.addItem(MenuItem(title: "Quit", key: "q") {
    //   self.prefDelegate?.preferenceDidQuit()
    // })
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
