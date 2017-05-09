extension Pref {
  class OpenAtLogin: BaseMenuItem {
    required convenience init() {
      self.init(title: "Open At Login", isChecked: App.autostart)
    }

    override func onDidClick() {
      isChecked = !isChecked
      if isChecked {
        broadcast(.openOnLogin)
      } else {
        broadcast(.doNotOpenOnLogin)
      }
    }
  }
}
