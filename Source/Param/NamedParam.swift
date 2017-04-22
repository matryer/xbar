// TODO: Rename class to Argument, as its an argument to 'bash'
// TODO: (2) The parser should not add params with the rest of the params
final class NamedParam: Param<String> {
  var index: Int = 0
  override var key: String {
    return "param" + String(index)
  }
  override var original: String {
    return escape(raw)
  }

  convenience init(_ key: Int, _ value: String) {
    self.init(value)
    self.index = key
  }

  override func menu(didLoad menu: Menuable) {
    menu.add(arg: value)
  }
}
