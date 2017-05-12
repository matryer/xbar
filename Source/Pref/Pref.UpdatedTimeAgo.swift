import DateToolsSwift

extension Pref {
  class UpdatedTimeAgo: MenuItem {
    let initAt = Date()

    required convenience init() {
      self.init(title: "Never ran", isClickable: false)
      touch()
    }

    func touch() {
      set(title: output)
    }

    private var output: String {
      return "Updated " + initAt.timeAgoSinceNow.lowercased()
    }
  }
}
