import DateTools

class UpdatedAgoItem: ItemBase {
  private var updatedAt = NSDate()

  init() {
    super.init("Never updated…")
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func touch() {
    set(title: getTitle())
  }

  private func getTitle() -> String {
    return "Updated " + updatedAt.timeAgoSinceNow().lowercased()
  }
}
