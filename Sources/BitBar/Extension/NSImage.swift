import AppKit

extension NSImage {
  convenience init?(data: Data, isTemplate: Bool) {
    self.init(data: data)
    self.isTemplate = isTemplate
  }
}
