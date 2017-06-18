extension Pref {
  class CLIPort: MenuItem {
    required convenience init() {
      self.init(title: "CLI port: \(App.port)", isClickable: false)
    }
  }
}
