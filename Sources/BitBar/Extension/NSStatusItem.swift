import AppKit
import Async

extension NSStatusItem: MenuBar {
  var tag: String? {
    get {
      if #available(OSX 10.12, *) {
        return autosaveName
      }

      return nil
    }
    set {
      if #available(OSX 10.12, *) {
        self.autosaveName = newValue
      }
    }
  }

  func show() {
    if #available(OSX 10.12, *) {
      self.isVisible = true
    }
  }

  func hide() {
    if #available(OSX 10.12, *) {
      self.isVisible = false
    }
  }
}
