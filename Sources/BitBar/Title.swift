import Parser
import BonMot
import Async

final class Title: MenuBase {
  private let ago = Pref.UpdatedTimeAgo()
  private let runInTerminal = Pref.RunInTerminal()
  private var numberOfPrefs = 0
  internal var hasLoaded: Bool = false

  init(prefs: [NSMenuItem], delegate root: Parent) {
    super.init()

    self.root = root
    self.numberOfPrefs = 4
    self.delegate = self

    add(submenu: NSMenuItem.separator(), at: 0)
    add(submenu: ago, at: 1)
    add(submenu: runInTerminal, at: 2)
    add(submenu: Pref.Preferences(prefs: prefs), at: 3)
  }

  // Only keep pref menus
  func set(menus: [NSMenuItem]) {
    reset()

    for (index, menu) in menus.enumerated() {
      add(submenu: menu, at: index)
    }

    ago.reset()
    hasLoaded = true
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func reset() {
    guard numberOfPrefs < numberOfItems else { return }
    for _ in numberOfPrefs..<numberOfItems {
      remove(at: 0)
    }
  }
}
