import DateToolsSwift

extension Pref {
  class UpdatedTimeAgo: BaseMenuItem {
    let since = Date()

    required convenience init() {
      self.init(title: "Never updated…", isClickable: false)
      touch()
    }

    func touch() {
      set(title: "Updated " + since.timeAgoSinceNow.lowercased())
    }
  }
}
