import Cocoa

protocol MenuDelegate {
  var title: String { get }
  func getTitle() -> String
  func onDidClick(block: @escaping () -> ())
  func useAsAlternate()
  func refresh()
  func getArgs() -> [String]
  func openTerminal() -> Bool
  func shouldRefresh() -> Bool
  func update(attr: NSMutableAttributedString)
  func update(state: Int)
  func update(color: NSColor)
  func update(fontName: String)
  func update(size: Int)
  func update(image: NSImage, isTemplate: Bool)
  func update(title: String)
}