import Cocoa

/* TODO: Explain */
protocol MenuDelegate: class {
  var title: String { get }
  func getTitle() -> String
  func getAttrs() -> NSMutableAttributedString
  func onDidClick(block: @escaping () -> Void)
  func useAsAlternate()
  func refresh()
  func getArgs() -> [String]
  func openTerminal() -> Bool
  func shouldRefresh() -> Bool
  func update(attr: NSMutableAttributedString)
  func update(state: Int)
  func update(color: NSColor)
  func update(fontName: String)
  func update(size: Float)
  func update(image: NSImage, isTemplate: Bool)
  func update(title: String)
}
