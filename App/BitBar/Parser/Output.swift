import EmitterKit

final public class Output {
  internal let title: Title
  internal let isStream: Bool
  private var listeners = [Listener]()
  private var openInTerminalClickEvent = Event<Void>()
  private var triggerRefreshEvent = Event<Void>()

  init(_ title: Title, _ isStream: Bool) {
    self.title = title
    self.isStream = isStream

    title.onDidClickOpenInTerminal {
      self.openInTerminalClickEvent.emit()
    }

    title.onDidTriggerRefresh {
      self.triggerRefreshEvent.emit()
    }
  }

  func destroy() {
    title.destroy()
  }

  func onDidClickOpenInTerminal(block: @escaping Block<Void>) {
    listeners.append(openInTerminalClickEvent.on(block))
  }

  func onDidTriggerRefresh(block: @escaping Block<Void>) {
    listeners.append(triggerRefreshEvent.on(block))
  }

  deinit { destroy() }
}
