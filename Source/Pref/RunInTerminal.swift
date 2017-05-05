import Cocoa
import DateToolsSwift

class RunInTerminal: ItemBase {
  init() {
    super.init("Run in Terminal…", key: "o")
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc override func didClick(_ sender: NSMenu) {
    parentable?.didClickOpenInTerminal()
  }
}
