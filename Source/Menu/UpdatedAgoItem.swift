import Cocoa
import DateToolsSwift

class UpdatedAgoItem: ItemBase {
  private var updatedAt = Date()

  init() {
    super.init("Never updated…")
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func touch() {
    set(title: getTitle())
  }

  func refresh() {
    updatedAt = Date()
    touch()
  }

  private func getTitle() -> String {
    return "Updated " + updatedAt.timeAgoSinceNow.lowercased()
  }
}
