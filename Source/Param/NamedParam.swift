/* TODO: Move this somewhere else */
func escape(_ value: String, quote: String = "\"") -> String {
  return quote + value.replace("\\", "\\\\").replace(quote, "\\" + quote) + quote
}

// TODO: Rename class to Argument, as its an argument to 'bash'
final class NamedParam: Param<String> {
  var index: Int = 0
  override var key: String { return "param" + String(index) }
  override var original: String { return escape(raw) }
  convenience init(_ key: Int, _ value: String) {
    self.init(value)
    self.index = key
  }

  override func menu(didLoad menu: Menuable) {
    menu.add(arg: value)
  }
}
