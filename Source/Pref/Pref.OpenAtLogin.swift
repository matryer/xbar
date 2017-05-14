extension Pref {
  class OpenAtLogin: MenuItem {
    required convenience init(openAtLogin: Bool) {
      self.init(title: "Open at Login", isChecked: openAtLogin, isClickable: true)
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
