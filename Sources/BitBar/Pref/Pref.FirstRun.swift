import DateToolsSwift

extension Pref {
  class FirstRun: MenuItem {
    let startedAt = Date()

    override func onWillBecomeVisible() {
      set(title: "Started At: " + startedAt.timeAgoSinceNow.capitalized)
    }
  }
}
