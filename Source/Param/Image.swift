import AppKit

class Image<T: Equatable>: Param<T> {
  override var key: String {
    return isTemplate ? "templateImage" : "image"
  }
  var isTemplate = false

  convenience init(_ value: T, isTemplate: Bool) {
    self.init(value)
    self.isTemplate = isTemplate
  }
}
