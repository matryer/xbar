import DateToolsSwift

extension Pref {
  class UpdatedTimeAgo: MenuItem {
    var initAt = Date()

    func reset() {
      initAt = Date()
    }

    override func onWillBecomeVisible() {
      set(title: "Updated " + initAt.timeAgoSinceNow.lowercased())
    }
  }
}
