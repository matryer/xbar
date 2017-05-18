import Parser
import BonMot

final class Title: MenuBase, Parent {
  weak var root: Parent?
  private let ago = Pref.UpdatedTimeAgo()
  private let runInTerminal = Pref.RunInTerminal()
  private var numberOfPrefs = 0
  internal var hasLoaded: Bool = false

  init(prefs: [NSMenuItem], delegate: Parent) {
    super.init()
    root = delegate
    add(sub: NSMenuItem.separator())
    add(sub: ago)
    add(sub: runInTerminal)
    add(sub: Pref.Preferences(prefs: prefs))
    numberOfPrefs = numberOfItems
    self.delegate = self
  }

  init(x: Int) {
    super.init()
  }

  // Only keep pref menus
  func set(menus: [NSMenuItem]) {
    for _ in numberOfPrefs..<numberOfItems {
      removeItem(at: 0)
    }

    for menu in menus {
      add(sub: menu)
    }

    ago.reset()
    hasLoaded = true
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func add(sub: NSMenuItem) {
    sub.root = self
    insertItem(sub, at: numberOfItems - numberOfPrefs)
  }
}
