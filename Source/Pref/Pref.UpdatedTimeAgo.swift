import DateToolsSwift

extension Pref {
  class UpdatedTimeAgo: MenuItem {
    let initAt = Date()

    override func onWillBecomeVisible() {
      set(title: "Updated " + initAt.timeAgoSinceNow.lowercased())
    }
  }
}
