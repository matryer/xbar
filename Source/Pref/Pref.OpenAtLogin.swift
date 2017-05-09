extension Pref {
  class OpenAtLogin: BaseMenuItem {
    required convenience init(openAtLogin: Bool) {
      self.init(title: "Open at Login", isChecked: openAtLogin)
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
