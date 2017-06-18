extension Pref {
  class AppVersion: MenuItem {
    required convenience init() {
      self.init(title: "Version: \(App.version)", isClickable: false)
    }
  }
}
